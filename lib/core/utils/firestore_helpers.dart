import 'package:cloud_firestore/cloud_firestore.dart';

/// Small readers shared by all models.
DateTime? readDate(Object? v) => v is Timestamp ? v.toDate() : null;
double? readDouble(Object? v) => v is num ? v.toDouble() : null;
T readEnum<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.firstWhere((e) => e.name == name, orElse: () => fallback);
