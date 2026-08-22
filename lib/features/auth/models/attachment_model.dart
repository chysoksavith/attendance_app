class AttachmentModel {
  final int id;
  final String fileName;
  final String url;
  final String? mimeType;
  final int? size;
  final String? collectionName;

  const AttachmentModel({
    required this.id,
    required this.fileName,
    required this.url,
    this.mimeType,
    this.size,
    this.collectionName,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fileName: json['file_name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      mimeType: json['mime_type']?.toString(),
      size: json['size'] is int ? json['size'] as int : int.tryParse(json['size']?.toString() ?? ''),
      collectionName: json['collection_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'url': url,
      'mime_type': mimeType,
      'size': size,
      'collection_name': collectionName,
    };
  }
}
