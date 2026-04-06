import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LeadsRecord extends FirestoreRecord {
  LeadsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "ownerUid" field.
  String? _ownerUid;
  String get ownerUid => _ownerUid ?? '';
  bool hasOwnerUid() => _ownerUid != null;

  // "source" field.
  String? _source;
  String get source => _source ?? '';
  bool hasSource() => _source != null;

  // "companyName" field.
  String? _companyName;
  String get companyName => _companyName ?? '';
  bool hasCompanyName() => _companyName != null;

  // "website" field.
  String? _website;
  String get website => _website ?? '';
  bool hasWebsite() => _website != null;

  // "afm" field.
  String? _afm;
  String get afm => _afm ?? '';
  bool hasAfm() => _afm != null;

  // "legalForm" field.
  String? _legalForm;
  String get legalForm => _legalForm ?? '';
  bool hasLegalForm() => _legalForm != null;

  // "hqAddress" field.
  String? _hqAddress;
  String get hqAddress => _hqAddress ?? '';
  bool hasHqAddress() => _hqAddress != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  bool hasCity() => _city != null;

  // "naceCode" field.
  String? _naceCode;
  String get naceCode => _naceCode ?? '';
  bool hasNaceCode() => _naceCode != null;

  // "secondaryNaceCodes" field.
  List<String>? _secondaryNaceCodes;
  List<String> get secondaryNaceCodes => _secondaryNaceCodes ?? const [];
  bool hasSecondaryNaceCodes() => _secondaryNaceCodes != null;

  // "scoreBand" field.
  String? _scoreBand;
  String get scoreBand => _scoreBand ?? 'LOW';
  bool hasScoreBand() => _scoreBand != null;

  // "scoreValue" field.
  double? _scoreValue;
  double get scoreValue => _scoreValue ?? 0.0;
  bool hasScoreValue() => _scoreValue != null;

  // "fitReason" field.
  String? _fitReason;
  String get fitReason => _fitReason ?? '';
  bool hasFitReason() => _fitReason != null;

  // "status" field.
  String? _status;
  String get status => _status ?? 'new';
  bool hasStatus() => _status != null;

  // "radarRunId" field.
  String? _radarRunId;
  String get radarRunId => _radarRunId ?? '';
  bool hasRadarRunId() => _radarRunId != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _ownerUid = snapshotData['ownerUid'] as String?;
    _source = snapshotData['source'] as String?;
    _companyName = snapshotData['companyName'] as String?;
    _website = snapshotData['website'] as String?;
    _afm = snapshotData['afm'] as String?;
    _legalForm = snapshotData['legalForm'] as String?;
    _hqAddress = snapshotData['hqAddress'] as String?;
    _city = snapshotData['city'] as String?;
    _naceCode = snapshotData['naceCode'] as String?;
    _secondaryNaceCodes = getDataList(snapshotData['secondaryNaceCodes']);
    _scoreBand = snapshotData['scoreBand'] as String?;
    _scoreValue = castToType<double>(snapshotData['scoreValue']);
    _fitReason = snapshotData['fitReason'] as String?;
    _status = snapshotData['status'] as String?;
    _radarRunId = snapshotData['radarRunId'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('leads');

  static Stream<LeadsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LeadsRecord.fromSnapshot(s));

  static Future<LeadsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LeadsRecord.fromSnapshot(s));

  static LeadsRecord fromSnapshot(DocumentSnapshot snapshot) => LeadsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LeadsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LeadsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LeadsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LeadsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLeadsRecordData({
  String? ownerUid,
  String? source,
  String? companyName,
  String? website,
  String? afm,
  String? legalForm,
  String? hqAddress,
  String? city,
  String? naceCode,
  String? scoreBand,
  double? scoreValue,
  String? fitReason,
  String? status,
  String? radarRunId,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ownerUid': ownerUid,
      'source': source,
      'companyName': companyName,
      'website': website,
      'afm': afm,
      'legalForm': legalForm,
      'hqAddress': hqAddress,
      'city': city,
      'naceCode': naceCode,
      'scoreBand': scoreBand,
      'scoreValue': scoreValue,
      'fitReason': fitReason,
      'status': status,
      'radarRunId': radarRunId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class LeadsRecordDocumentEquality implements Equality<LeadsRecord> {
  const LeadsRecordDocumentEquality();

  @override
  bool equals(LeadsRecord? e1, LeadsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.ownerUid == e2?.ownerUid &&
        e1?.source == e2?.source &&
        e1?.companyName == e2?.companyName &&
        e1?.website == e2?.website &&
        e1?.afm == e2?.afm &&
        e1?.legalForm == e2?.legalForm &&
        e1?.hqAddress == e2?.hqAddress &&
        e1?.city == e2?.city &&
        e1?.naceCode == e2?.naceCode &&
        listEquality.equals(e1?.secondaryNaceCodes, e2?.secondaryNaceCodes) &&
        e1?.scoreBand == e2?.scoreBand &&
        e1?.scoreValue == e2?.scoreValue &&
        e1?.fitReason == e2?.fitReason &&
        e1?.status == e2?.status &&
        e1?.radarRunId == e2?.radarRunId &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(LeadsRecord? e) => const ListEquality().hash([
        e?.ownerUid,
        e?.source,
        e?.companyName,
        e?.website,
        e?.afm,
        e?.legalForm,
        e?.hqAddress,
        e?.city,
        e?.naceCode,
        e?.secondaryNaceCodes,
        e?.scoreBand,
        e?.scoreValue,
        e?.fitReason,
        e?.status,
        e?.radarRunId,
        e?.createdAt,
        e?.updatedAt,
      ]);

  @override
  bool isValidKey(Object? o) => o is LeadsRecord;
}
