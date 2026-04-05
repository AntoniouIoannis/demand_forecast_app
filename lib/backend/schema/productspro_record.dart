import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProductsproRecord extends FirestoreRecord {
  ProductsproRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "sale_price" field.
  double? _salePrice;
  double get salePrice => _salePrice ?? 0.0;
  bool hasSalePrice() => _salePrice != null;

  // "quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _price = castToType<double>(snapshotData['price']);
    _createdAt = snapshotData['created_at'] as DateTime?;
    _salePrice = castToType<double>(snapshotData['sale_price']);
    _quantity = castToType<int>(snapshotData['quantity']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('productspro');

  static Stream<ProductsproRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ProductsproRecord.fromSnapshot(s));

  static Future<ProductsproRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ProductsproRecord.fromSnapshot(s));

  static ProductsproRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ProductsproRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ProductsproRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ProductsproRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ProductsproRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ProductsproRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createProductsproRecordData({
  String? name,
  String? description,
  double? price,
  DateTime? createdAt,
  double? salePrice,
  int? quantity,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'created_at': createdAt,
      'sale_price': salePrice,
      'quantity': quantity,
    }.withoutNulls,
  );

  return firestoreData;
}

class ProductsproRecordDocumentEquality implements Equality<ProductsproRecord> {
  const ProductsproRecordDocumentEquality();

  @override
  bool equals(ProductsproRecord? e1, ProductsproRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        e1?.price == e2?.price &&
        e1?.createdAt == e2?.createdAt &&
        e1?.salePrice == e2?.salePrice &&
        e1?.quantity == e2?.quantity;
  }

  @override
  int hash(ProductsproRecord? e) => const ListEquality().hash([
        e?.name,
        e?.description,
        e?.price,
        e?.createdAt,
        e?.salePrice,
        e?.quantity
      ]);

  @override
  bool isValidKey(Object? o) => o is ProductsproRecord;
}
