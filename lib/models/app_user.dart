import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? catName;
  final String? breed;
  final bool introCompleted;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.catName,
    this.breed,
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
      catName: data['catName'] as String?,
      breed: data['breed'] as String?,
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
      'breed': breed,
      'introCompleted': introCompleted,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  /// ✅ copyWith method for state updates
  AppUser copyWith({
    String? uid,
    String? email,
    String? catName,
    String? breed,
    bool? introCompleted,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      catName: catName ?? this.catName,
      breed: breed ?? this.breed,
      introCompleted: introCompleted ?? this.introCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
