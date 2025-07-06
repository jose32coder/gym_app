import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  final String? id;
  final String name;
  final double discount;
  final Map<int, double> groupDiscount;
  final bool isActive;

  PromotionModel({
    this.id,
    required this.name,
    required this.discount,
    required this.groupDiscount,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'discount': discount,
      'groupDiscount':
          groupDiscount.map((key, value) => MapEntry(key.toString(), value)),
      'isActive': isActive,
    };
  }

  // Factory para crear desde un Map
  factory PromotionModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawGroupDiscount =
        map['groupDiscount'] as Map<String, dynamic>? ?? {};
    final groupDiscount = rawGroupDiscount.map<int, double>((key, value) {
      final intKey = int.tryParse(key) ?? 0;
      final doubleValue = (value is num) ? value.toDouble() : 0.0;
      return MapEntry(intKey, doubleValue);
    });

    return PromotionModel(
      id: docId,
      name: map['name'] ?? '',
      discount: (map['discount'] != null)
          ? (map['discount'] is num)
              ? (map['discount'] as num).toDouble()
              : (map['discount'] is String)
                  ? double.tryParse(map['discount']) ?? 0.0
                  : 0.0
          : 0.0,
      groupDiscount: groupDiscount,
    );
  }

  // Factory para crear desde un DocumentSnapshot
  factory PromotionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawGroupDiscount =
        data['groupDiscount'] as Map<String, dynamic>? ?? {};
    final groupDiscount = rawGroupDiscount.map<int, double>((key, value) {
      final intKey = int.tryParse(key) ?? 0;
      final doubleValue = (value is num) ? value.toDouble() : 0.0;
      return MapEntry(intKey, doubleValue);
    });

    return PromotionModel(
      id: doc.id,
      name: data['name'] ?? '',
      discount: (data['discount'] != null)
          ? (data['discount'] is num)
              ? (data['discount'] as num).toDouble()
              : (data['discount'] is String)
                  ? double.tryParse(data['discount']) ?? 0.0
                  : 0.0
          : 0.0,
      groupDiscount: groupDiscount,
      isActive: data['isActive'] is bool ? data['isActive'] : false,
    );
  }
}
