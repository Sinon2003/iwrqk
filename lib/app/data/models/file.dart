class FileModel {
  String id;
  String? path;
  String? name;
  int? duration;
  int? size;
  int? numThumbnails;
  String? createdAt;
  String? updatedAt;
  bool? animatedPreview;

  FileModel({
    required this.id,
    this.path,
    this.name,
    this.duration,
    this.size,
    this.numThumbnails,
    this.createdAt,
    this.updatedAt,
    this.animatedPreview,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      path: json['path'],
      name: json['name'],
      duration: json['duration'],
      size: (json['size'] as num?)?.toInt(),
      numThumbnails: json['numThumbnails'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      animatedPreview: json['animatedPreview'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'duration': duration,
      'size': size,
      'numThumbnails': numThumbnails,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'animatedPreview': animatedPreview,
    };
  }
}
