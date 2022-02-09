class Review {
  final String? authorName;
  final String? language;
  final String? profilePhotoURL;
  final int? rating;
  final String? relativeTimeDescription;
  final String? text;
  Review(
      {this.authorName,
      this.language,
      this.profilePhotoURL,
      this.rating,
      this.relativeTimeDescription,
      this.text});

  factory Review.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Review(
        authorName: parsedJson['author_name'],
        language: parsedJson['language'],
        profilePhotoURL: parsedJson['profile_photo_url'],
        rating: parsedJson['rating'],
        relativeTimeDescription: parsedJson['relative_time_description'],
        text: parsedJson['text']);
  }
}
