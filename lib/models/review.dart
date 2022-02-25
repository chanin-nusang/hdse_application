class Review {
  final String? authorName;
  final String? language;
  final String? profilePhotoURL;
  final int? rating;
  final String? relativeTimeDescription;
  final String? text;
  final int? time;

  Review(
      {this.authorName,
      this.language,
      this.profilePhotoURL,
      this.rating,
      this.relativeTimeDescription,
      this.text,
      this.time});

  factory Review.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Review(
        authorName: parsedJson['author_name'] != null
            ? parsedJson['author_name']
            : null,
        language:
            parsedJson['language'] != null ? parsedJson['language'] : null,
        profilePhotoURL: parsedJson['profile_photo_url'] != null
            ? parsedJson['profile_photo_url']
            : null,
        rating: parsedJson['rating'] != null ? parsedJson['rating'] : null,
        relativeTimeDescription: parsedJson['relative_time_description'] != null
            ? parsedJson['relative_time_description']
            : null,
        text: parsedJson['text'] != null ? parsedJson['text'] : null,
        time: parsedJson['time'] != null ? parsedJson['time'] : null);
  }
}
