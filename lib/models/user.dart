class User {
  final String userId;
  String displayName;
  String email;
  Map<String, String> ownedCalendars;
  Map<String, String> followedCalendars;

  User({
    this.userId,
    this.displayName,
    this.email,
  });
}
