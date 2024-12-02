class ChannelModel {
  final String? imagePath;
  final String? title;
  final String? description;
  final int? subscribers;
  final String? id; // Optional ID field

  const ChannelModel({
    this.imagePath,
    this.title,
    this.description,
    this.subscribers,
    this.id, // Allow id to be nullable
  });

  // Convert object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "imagePath": imagePath,
      "title": title,
      "description": description,
      "subscribers": subscribers,
    };
  }

  // Factory constructor to create an object from Firestore data
  factory ChannelModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ChannelModel(
      imagePath: json['imagePath'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subscribers: json['subscribers'] ?? 0,
      id: id, // Assign the document ID here
    );
  }
}
