import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OnholdUsersRecord extends FirestoreRecord {
  OnholdUsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "password" field.
  String? _password;
  String get password => _password ?? '';
  bool hasPassword() => _password != null;

  // "repassword" field.
  String? _repassword;
  String get repassword => _repassword ?? '';
  bool hasRepassword() => _repassword != null;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _email = snapshotData['email'] as String?;
    _password = snapshotData['password'] as String?;
    _repassword = snapshotData['repassword'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('onhold_users');

  static Stream<OnholdUsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OnholdUsersRecord.fromSnapshot(s));

  static Future<OnholdUsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OnholdUsersRecord.fromSnapshot(s));

  static OnholdUsersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      OnholdUsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OnholdUsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OnholdUsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OnholdUsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OnholdUsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOnholdUsersRecordData({
  String? uid,
  String? phoneNumber,
  String? email,
  String? password,
  String? repassword,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'phone_number': phoneNumber,
      'email': email,
      'password': password,
      'repassword': repassword,
    }.withoutNulls,
  );

  return firestoreData;
}

class OnholdUsersRecordDocumentEquality implements Equality<OnholdUsersRecord> {
  const OnholdUsersRecordDocumentEquality();

  @override
  bool equals(OnholdUsersRecord? e1, OnholdUsersRecord? e2) {
    return e1?.uid == e2?.uid &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.email == e2?.email &&
        e1?.password == e2?.password &&
        e1?.repassword == e2?.repassword;
  }

  @override
  int hash(OnholdUsersRecord? e) => const ListEquality()
      .hash([e?.uid, e?.phoneNumber, e?.email, e?.password, e?.repassword]);

  @override
  bool isValidKey(Object? o) => o is OnholdUsersRecord;
}
