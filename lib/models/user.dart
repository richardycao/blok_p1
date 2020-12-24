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
    this.ownedCalendars,
    this.followedCalendars,
  });

  factory User.fromMap(Map data) {
    data = data ?? {};
    return User(
      userId: data['userId'] as String ?? "null",
      displayName: data['displayName'] as String ?? "null",
      email: data['email'] as String ?? "null",
      ownedCalendars: Map<String, String>.from(data['ownedCalendars']) ?? {},
      followedCalendars:
          Map<String, String>.from(data['followedCalendars']) ?? {},
    );
  }
}
