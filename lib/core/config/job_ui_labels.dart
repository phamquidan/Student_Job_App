typedef LabelOption = ({String id, String label});

abstract final class JobUiLabels {
  static const sourceOptions = <LabelOption>[
    (id: 'all', label: 'Tất cả nguồn'),
    (id: 'manual', label: 'Nội bộ'),
    (id: 'api', label: 'API'),
    (id: 'recruiter', label: 'Nhà tuyển dụng'),
  ];

  static const quickTagOptions = <LabelOption>[
    (id: 'all', label: 'Tất cả'),
    (id: 'remote', label: 'Làm từ xa'),
    (id: 'internship', label: 'Thực tập'),
    (id: 'part-time', label: 'Bán thời gian'),
    (id: 'full-time', label: 'Toàn thời gian'),
  ];

  static const recruiterTypeOptions = <LabelOption>[
    (id: 'internship', label: 'Thực tập'),
    (id: 'part-time', label: 'Bán thời gian'),
  ];

  static const postTypeOptions = <LabelOption>[
    (id: 'Internship', label: 'Thực tập'),
    (id: 'Part-time', label: 'Bán thời gian'),
    (id: 'Full-time', label: 'Toàn thời gian'),
    (id: 'Remote', label: 'Làm từ xa'),
  ];

  static String postTypeLabel(String id) {
    for (final option in postTypeOptions) {
      if (option.id == id) return option.label;
    }
    return id;
  }
}
