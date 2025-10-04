import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final bool introCompleted;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.introCompleted = false,
    this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    final created = data['createdAt'];

    DateTime? createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is DateTime) {
      createdAt = created;
    } else if (created is String) {
      createdAt = DateTime.tryParse(created);
    }

    return AppUser(
      uid: uid,
      email: data['email'] is String ? data['email'] as String : '',
      introCompleted: (data['introCompleted'] ?? false) as bool,
      createdAt: createdAt,
    );
  }

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return AppUser.fromMap(doc.id, doc.data() ?? {});
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'introCompleted': introCompleted,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    bool? introCompleted,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      introCompleted: introCompleted ?? this.introCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
