import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NotificationsRecord extends FirestoreRecord {
  NotificationsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "ownerUid" field.
  String? _ownerUid;
  String get ownerUid => _ownerUid ?? '';
  bool hasOwnerUid() => _ownerUid != null;

  // "leadId" field.
  String? _leadId;
  String get leadId => _leadId ?? '';
  bool hasLeadId() => _leadId != null;

  // "companyName" field.
  String? _companyName;
  String get companyName => _companyName ?? '';
  bool hasCompanyName() => _companyName != null;

  // "channel" field — "email" | "in_app"
  String? _channel;
  String get channel => _channel ?? 'email';
  bool hasChannel() => _channel != null;

  // "template" field — "B2B" | "B2C"
  String? _template;
  String get template => _template ?? '';
  bool hasTemplate() => _template != null;

  // "deliveryStatus" field — "queued" | "sent" | "failed"
  String? _deliveryStatus;
  String get deliveryStatus => _deliveryStatus ?? 'queued';
  bool hasDeliveryStatus() => _deliveryStatus != null;

  // "errorMessage" field.
  String? _errorMessage;
  String get errorMessage => _errorMessage ?? '';
  bool hasErrorMessage() => _errorMessage != null;

  // "sentAt" field.
  DateTime? _sentAt;
  DateTime? get sentAt => _sentAt;
  bool hasSentAt() => _sentAt != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _ownerUid = snapshotData['ownerUid'] as String?;
    _leadId = snapshotData['leadId'] as String?;
    _companyName = snapshotData['companyName'] as String?;
    _channel = snapshotData['channel'] as String?;
    _template = snapshotData['template'] as String?;
    _deliveryStatus = snapshotData['deliveryStatus'] as String?;
    _errorMessage = snapshotData['errorMessage'] as String?;
    _sentAt = snapshotData['sentAt'] as DateTime?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notifications');

  static Stream<NotificationsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificationsRecord.fromSnapshot(s));

  static Future<NotificationsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificationsRecord.fromSnapshot(s));

  static NotificationsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificationsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificationsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificationsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificationsRecordData({
  String? ownerUid,
  String? leadId,
  String? companyName,
  String? channel,
  String? template,
  String? deliveryStatus,
  String? errorMessage,
  DateTime? sentAt,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ownerUid': ownerUid,
      'leadId': leadId,
      'companyName': companyName,
      'channel': channel,
      'template': template,
      'deliveryStatus': deliveryStatus,
      'errorMessage': errorMessage,
      'sentAt': sentAt,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificationsRecordDocumentEquality
    implements Equality<NotificationsRecord> {
  const NotificationsRecordDocumentEquality();

  @override
  bool equals(NotificationsRecord? e1, NotificationsRecord? e2) {
    return e1?.ownerUid == e2?.ownerUid &&
        e1?.leadId == e2?.leadId &&
        e1?.companyName == e2?.companyName &&
        e1?.channel == e2?.channel &&
        e1?.template == e2?.template &&
        e1?.deliveryStatus == e2?.deliveryStatus &&
        e1?.errorMessage == e2?.errorMessage &&
        e1?.sentAt == e2?.sentAt &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(NotificationsRecord? e) => const ListEquality().hash([
        e?.ownerUid,
        e?.leadId,
        e?.companyName,
        e?.channel,
        e?.template,
        e?.deliveryStatus,
        e?.errorMessage,
        e?.sentAt,
        e?.createdAt,
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificationsRecord;
}
