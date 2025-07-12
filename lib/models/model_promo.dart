import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  final String? id;
  final String name;
  final double discount;
  final Map<int, double> groupDiscount;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  PromotionModel({
    this.id,
    required this.name,
    required this.discount,
    required this.groupDiscount,
    this.isActive = true,
    this.createdAt,
    this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'discount': discount,
      'groupDiscount':
          groupDiscount.map((key, value) => MapEntry(key.toString(), value)),
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  factory PromotionModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawGroupDiscount =
        map['groupDiscount'] as Map<String, dynamic>? ?? {};
    final groupDiscount = rawGroupDiscount.map<int, double>((key, value) {
      final intKey = int.tryParse(key) ?? 0;
      final doubleValue = (value is num) ? value.toDouble() : 0.0;
      return MapEntry(intKey, doubleValue);
    });

    DateTime? createdAt = map['createdAt'] != null
        ? (map['createdAt'] as Timestamp).toDate()
        : null;

    DateTime? expiresAt = map['expiresAt'] != null
        ? (map['expiresAt'] as Timestamp).toDate()
        : null;

    // Lógica para calcular si está activa según fecha de expiración
    final now = DateTime.now();
    bool isActive = true;
    if (expiresAt != null) {
      isActive = now.isBefore(expiresAt);
    } else {
      isActive = map['isActive'] is bool ? map['isActive'] : true;
    }

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
      createdAt: createdAt,
      expiresAt: expiresAt,
      isActive: isActive,
    );
  }

  factory PromotionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawGroupDiscount =
        data['groupDiscount'] as Map<String, dynamic>? ?? {};
    final groupDiscount = rawGroupDiscount.map<int, double>((key, value) {
      final intKey = int.tryParse(key) ?? 0;
      final doubleValue = (value is num) ? value.toDouble() : 0.0;
      return MapEntry(intKey, doubleValue);
    });

    DateTime? createdAt = data['createdAt'] != null
        ? (data['createdAt'] as Timestamp).toDate()
        : null;

    DateTime? expiresAt = data['expiresAt'] != null
        ? (data['expiresAt'] as Timestamp).toDate()
        : null;

    final now = DateTime.now();
    bool isActive = true;
    if (expiresAt != null) {
      isActive = now.isBefore(expiresAt);
    } else {
      isActive = data['isActive'] is bool ? data['isActive'] : true;
    }

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
      createdAt: createdAt,
      expiresAt: expiresAt,
      isActive: isActive,
    );
  }
}
