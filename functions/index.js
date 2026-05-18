const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

async function getUserRole(uid) {
  const userSnap = await db.collection("users").doc(uid).get();
  const data = userSnap.data() || {};
  return data.role || "student";
}

exports.createJob = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "Bạn cần đăng nhập.");
  }

  const role = await getUserRole(auth.uid);
  if (role !== "recruiter") {
    throw new HttpsError("permission-denied", "Chỉ recruiter mới được đăng tin.");
  }

  const payload = request.data || {};
  const title = String(payload.title || "").trim();
  const companyName = String(payload.companyName || "").trim();
  const location = String(payload.location || "").trim();
  const salaryText = String(payload.salaryText || "").trim();
  const description = String(payload.description || "").trim();
  const jobType = String(payload.jobType || "Internship");
  const category = String(payload.category || "Công nghệ thông tin");

  if (!title || !companyName || !location || !salaryText || !description) {
    throw new HttpsError("invalid-argument", "Thiếu dữ liệu bắt buộc.");
  }

  const docRef = db.collection("jobs").doc();
  await docRef.set({
    id: docRef.id,
    title,
    companyName,
    location,
    salaryText,
    jobType,
    category,
    description,
    requirements: "Đang cập nhật",
    benefits: "Đang cập nhật",
    source: "recruiter",
    applyType: "internal",
    applyUrl: "",
    status: "open",
    createdBy: auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { id: docRef.id };
});

exports.updateApplicationStatus = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "Bạn cần đăng nhập.");
  }

  const role = await getUserRole(auth.uid);
  if (role !== "recruiter") {
    throw new HttpsError("permission-denied", "Chỉ recruiter mới được cập nhật trạng thái.");
  }

  const payload = request.data || {};
  const targetUserId = String(payload.userId || "");
  const applicationId = String(payload.applicationId || "");
  const status = String(payload.status || "");

  if (!targetUserId || !applicationId || !status) {
    throw new HttpsError("invalid-argument", "Thiếu dữ liệu bắt buộc.");
  }

  const userRef = db
    .collection("users")
    .doc(targetUserId)
    .collection("applications")
    .doc(applicationId);
  const globalRef = db.collection("applications").doc(applicationId);

  const updatePayload = {
    status,
    reviewedBy: auth.uid,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const batch = db.batch();
  batch.set(userRef, updatePayload, { merge: true });
  batch.set(globalRef, updatePayload, { merge: true });
  await batch.commit();

  return { ok: true };
});
