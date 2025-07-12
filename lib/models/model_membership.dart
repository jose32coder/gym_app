import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipModel {
  final String? id;
  final String name;
  final double? price;
  final String membershipType;
  final bool isActive; // ejemplo: {2: 5, 3: 10, 4: 15}

  MembershipModel({
    this.id,
    required this.name,
    required this.price,
    required this.membershipType,
    required this.isActive,
    
  });

  factory MembershipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MembershipModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      membershipType: data['membershipType'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}
