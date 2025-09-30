import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? catName;
  final bool introCompleted;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.catName,
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
    } else {
      createdAt = null;
    }

    return AppUser(
      uid: uid,
      email: (data['email'] ?? '') as String,
      catName: data['catName'] as String?,
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
      'catName': catName,
      'introCompleted': introCompleted,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
