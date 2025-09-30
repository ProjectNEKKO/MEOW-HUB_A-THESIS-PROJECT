import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? catName;
  final bool introCompleted;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.catName,
    this.introCompleted = false,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      catName: data['catName'],
      introCompleted: data['introCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'catName': catName,
      'introCompleted': introCompleted,
      'createdAt': createdAt,
    };
  }
}
