import 'package:cloud_firestore/cloud_firestore.dart';

class Cat {
  final String uid; // Firestore doc ID
  final String name;
  final String? breed;
  final int? age;
  final String? photoUrl;
  final DateTime? createdAt;

  Cat({
    required this.uid,
    required this.name,
    this.breed,
    this.age,
    this.photoUrl,
    this.createdAt,
  });

  factory Cat.fromMap(String uid, Map<String, dynamic> data) {
    final created = data['createdAt'];

    DateTime? createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    } else if (created is DateTime) {
      createdAt = created;
    }

    return Cat(
      uid: uid,
      name: data['name'] ?? '',
      breed: data['breed'],
      age: data['age'],
      photoUrl: data['photoUrl'],
      createdAt: createdAt,
    );
  }

  factory Cat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Cat.fromMap(doc.id, doc.data() ?? {});
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breed': breed,
      'age': age,
      'photoUrl': photoUrl,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  Cat copyWith({
    String? uid,
    String? name,
    String? breed,
    int? age,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return Cat(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
