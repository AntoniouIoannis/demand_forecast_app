import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/gov_data/gemi_opendata_service.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

String _decodeMojibakeIfNeeded(String input) {
  if (input.isEmpty) return input;

  const badMarkers = <String>['Ã', 'Î', 'Ï', 'â', 'ð', '�'];
  final looksBroken = badMarkers.any(input.contains);
  if (!looksBroken) return input;

  try {
    final repaired = utf8.decode(latin1.encode(input), allowMalformed: true);
    final stillBroken = badMarkers.any(repaired.contains);
    if (!stillBroken && repaired.trim().isNotEmpty) {
      return repaired;
    }
  } catch (_) {
    // Keep original text if conversion fails.
  }

  return input;
}

String _asDisplayText(dynamic value, {String fallback = '-'}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  if (text.isEmpty) return fallback;
  return _decodeMojibakeIfNeeded(text);
}

String _asOptionalText(dynamic value) {
  final text = _asDisplayText(value, fallback: '');
  return text == '-' ? '' : text;
}

String _normalizeWebsite(String value) {
  var v = value.trim().toLowerCase();
  if (v.isEmpty) return v;
  v = v.replaceFirst(RegExp(r'^https?://'), '');
  v = v.replaceFirst(RegExp(r'^www\.'), '');
  if (v.endsWith('/')) {
    v = v.substring(0, v.length - 1);
  }
  return v;
}

void _flattenToKeyValueRows(
  dynamic value,
  String path,
  List<List<String>> rows,
) {
  if (value == null) {
    rows.add(<String>[path, '-']);
    return;
  }

  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    if (map.isEmpty) {
      rows.add(<String>[path, '{}']);
      return;
    }
    map.forEach((k, v) {
      final nextPath = path.isEmpty ? k.toString() : '$path.${k.toString()}';
      _flattenToKeyValueRows(v, nextPath, rows);
    });
    return;
  }

  if (value is List) {
    if (value.isEmpty) {
      rows.add(<String>[path, '[]']);
      return;
    }
    for (var i = 0; i < value.length; i++) {
      _flattenToKeyValueRows(value[i], '$path[$i]', rows);
    }
    return;
  }

  rows.add(<String>[path, _decodeMojibakeIfNeeded(value.toString())]);
}

class RadarWidget extends StatelessWidget {
  const RadarWidget({super.key});

  static String routeName = 'Radar';
  static String routePath = 'radar';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        final uid = user?.uid;

        final profileStream = uid == null
            ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
            : FirebaseFirestore.instance
                .collection('onhold_users')
                .doc(uid)
                .snapshots();

        final leadsStream = uid == null
            ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
            : FirebaseFirestore.instance
                .collection('leads')
                .where('ownerUid', isEqualTo: uid)
                .orderBy('scoreValue', descending: true)
                .limit(20)
                .snapshots();

        final alertsStream = uid == null
            ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
            : FirebaseFirestore.instance
                .collection('notifications')
                .where('ownerUid', isEqualTo: uid)
                .orderBy('createdAt', descending: true)
                .limit(10)
                .snapshots();

        return Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            leading: IconButton(
              onPressed: () => context.safePop(),
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: FlutterFlowTheme.of(context).info),
            ),
            title: Row(
              children: [
                Text(
                  'Sales Radar',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontWeight,
                        ),
                        color: FlutterFlowTheme.of(context).info,
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(width: 10.0),
                const _PulsingDot(),
              ],
            ),
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // â”€â”€ Value Proposition Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _PitchBanner(),
                  const SizedBox(height: 18.0),

                  // â”€â”€ SME Profile Snapshot â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _SectionTitle(title: 'SME Profile Snapshot'),
                  const SizedBox(height: 10.0),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: profileStream,
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data() ?? <String, dynamic>{};
                      final websiteForApi = _asOptionalText(data['website']);
                      return _GemiLiveFieldsCard(website: websiteForApi);
                    },
                  ),
                  const SizedBox(height: 18.0),

                  // â”€â”€ Data Sources â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _SectionTitle(title: 'Live Data Sources'),
                  const SizedBox(height: 10.0),
                  _SourceCard(
                    icon: Icons.business_center_outlined,
                    source: 'businessportal.gr (ΓΕΜΗ)',
                    value: 'Νέες ενάρξεις εταιρειών, ΑΦΜ, Έδρα, ΚΑΔ.',
                    useCase: 'Καθημερινό feed φρέσκων B2B/B2C leads.',
                  ),
                  const SizedBox(height: 10.0),
                  _SourceCard(
                    icon: Icons.map_outlined,
                    source: 'gov.data.gr',
                    value: 'Ανοιχτά δεδομένα επιχειρηματικότητας ανά δήμο.',
                    useCase: 'Χαρτογράφηση αγοράς ανά περιοχή.',
                  ),
                  const SizedBox(height: 10.0),
                  _SourceCard(
                    icon: Icons.analytics_outlined,
                    source: 'ELSTAT / Eurostat',
                    value: 'Δομή NACE και στατιστικά ανά κλάδο.',
                    useCase: 'Ταξινόμηση targets βάσει NACE.',
                  ),
                  const SizedBox(height: 18.0),

                  // â”€â”€ Recent Email Alerts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _SectionTitle(title: 'Recent Email Alerts'),
                  const SizedBox(height: 10.0),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: alertsStream,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return _EmptyAlertState();
                      }
                      return Column(
                        children: docs.map((doc) {
                          final n = doc.data();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _AlertTile(
                              companyName: _asDisplayText(
                                n['companyName'],
                                fallback: 'Unknown',
                              ),
                              template:
                                  _asDisplayText(n['template'], fallback: ''),
                              status: _asDisplayText(
                                n['deliveryStatus'],
                                fallback: 'queued',
                              ),
                              createdAt: n['createdAt'] as Timestamp?,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 18.0),

                  // â”€â”€ Potential Customers (Leads) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _SectionTitle(title: 'Potential Customers (Leads)'),
                  const SizedBox(height: 10.0),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: leadsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return _EmptyLeadState();
                      }
                      return Column(
                        children: docs.map((doc) {
                          final lead = doc.data();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _LeadCard(
                              name: _asDisplayText(
                                lead['companyName'],
                                fallback: 'Unknown',
                              ),
                              website: _asDisplayText(lead['website']),
                              city: _asDisplayText(lead['city']),
                              nace: _asDisplayText(lead['naceCode']),
                              legalForm: _asDisplayText(lead['legalForm']),
                              fitReason: _asDisplayText(lead['fitReason']),
                              scoreBand: _asDisplayText(lead['scoreBand'],
                                  fallback: 'LOW'),
                              scoreValue: ((lead['scoreValue'] as num?) ?? 0)
                                  .toDouble(),
                              source: _asDisplayText(lead['source'],
                                  fallback: 'ΓΕΜΗ'),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// â”€â”€ Pitch Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _PitchBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary,
            theme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar_rounded, color: theme.info, size: 22.0),
              const SizedBox(width: 8.0),
              Text(
                'Ραντάρ Πωλήσεων',
                style: GoogleFonts.interTight(
                  color: theme.info,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            'Σου φέρνω τα δεδομένα του ΓΕΜΗ / ΕΛΣΤΑΤ στην οθόνη, φιλτραρισμένα για σένα.',
            style: GoogleFonts.inter(
              color: theme.info.withValues(alpha: 0.92),
              fontSize: 13.0,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Κάθε νέα επιχείρηση που ανοίγει στην Ελλάδα: email στο inbox σου την ίδια ημέρα.',
            style: GoogleFonts.inter(
              color: theme.info.withValues(alpha: 0.88),
              fontSize: 13.0,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Χτύπα πρώτος την πόρτα πριν προλάβουν οι μεγάλες αλυσίδες.',
            style: GoogleFonts.inter(
              color: theme.info.withValues(alpha: 0.88),
              fontSize: 13.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Pulsing Live Dot â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.25, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: _opacity.value),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4.0),
          Opacity(
            opacity: _opacity.value,
            child: Text(
              'LIVE',
              style: GoogleFonts.robotoMono(
                color: Colors.greenAccent,
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Alert Tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.companyName,
    required this.template,
    required this.status,
    required this.createdAt,
  });

  final String companyName;
  final String template;
  final String status;
  final Timestamp? createdAt;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bool sent = status == 'sent';
    final Color iconColor = sent ? Colors.green : Colors.redAccent;
    final IconData icon =
        sent ? Icons.mark_email_read_outlined : Icons.error_outline_rounded;

    String timeLabel = '';
    if (createdAt != null) {
      final dt = createdAt!.toDate().toLocal();
      timeLabel =
          '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: theme.bodyMedium.override(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Row(
                  children: [
                    _TypeBadge(type: template),
                    const SizedBox(width: 8.0),
                    if (timeLabel.isNotEmpty)
                      Text(
                        timeLabel,
                        style: theme.labelSmall.override(
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            sent ? 'Sent' : 'Failed',
            style: theme.labelSmall.override(
              color: iconColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final isB2B = type.toUpperCase() == 'B2B';
    final bg = isB2B ? Colors.blue.shade50 : Colors.purple.shade50;
    final fg = isB2B ? Colors.blue.shade700 : Colors.purple.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        type.isEmpty ? '-' : type.toUpperCase(),
        style: GoogleFonts.interTight(
          color: fg,
          fontSize: 10.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// â”€â”€ Section Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: FlutterFlowTheme.of(context).titleMedium.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
            letterSpacing: 0.0,
          ),
    );
  }
}

// ─── GEMI Live Fields Card ────────────────────────────────────────────────────
class _GemiLiveFieldsCard extends StatefulWidget {
  const _GemiLiveFieldsCard({required this.website});

  final String website;

  @override
  State<_GemiLiveFieldsCard> createState() => _GemiLiveFieldsCardState();
}

class _GemiLiveFieldsCardState extends State<_GemiLiveFieldsCard> {
  Future<Map<String, dynamic>?>? _future;
  String _lastNormalized = '';

  @override
  void initState() {
    super.initState();
    _launchIfNeeded(widget.website);
  }

  @override
  void didUpdateWidget(_GemiLiveFieldsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.website != widget.website) {
      _launchIfNeeded(widget.website);
    }
  }

  void _launchIfNeeded(String website) {
    final normalized = _normalizeWebsite(website);
    if (normalized == _lastNormalized) return;
    _lastNormalized = normalized;
    if (normalized.isEmpty) {
      setState(() => _future = null);
      return;
    }
    setState(() {
      _future = GemiOpenDataService.lookupCompanyByWebsite(normalized);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final normalized = _lastNormalized;

    if (normalized.isEmpty || _future == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: theme.alternate),
        ),
        child: Text(
          'Βάλε Business Website στο προφίλ σου για live άντληση στοιχείων από το ΓΕΜΗ API.',
          style: theme.bodyMedium.override(
            color: theme.secondaryText,
            letterSpacing: 0.0,
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: theme.alternate),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'Live κλήση στο ΓΕΜΗ API για $normalized ...',
                    style: theme.bodyMedium.override(letterSpacing: 0.0),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Text(
              'Αποτυχία live κλήσης ΓΕΜΗ API: ${snapshot.error}',
              style: theme.bodyMedium.override(
                color: Colors.red.shade700,
                letterSpacing: 0.0,
              ),
            ),
          );
        }

        final payload = snapshot.data;
        if (payload == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: theme.alternate),
            ),
            child: Text(
              'Δεν βρέθηκαν στοιχεία ΓΕΜΗ για website: $normalized',
              style: theme.bodyMedium.override(
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          );
        }

        final rows = <List<String>>[];
        _flattenToKeyValueRows(payload['company'], 'company', rows);
        _flattenToKeyValueRows(payload['documents'], 'documents', rows);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ΓΕΜΗ API Fields (Live)',
                style: theme.titleSmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 8.0),
              if (rows.isEmpty)
                Text(
                  'Δεν επιστράφηκαν πεδία από το API.',
                  style: theme.bodyMedium.override(
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                )
              else
                Column(
                  children: rows
                      .map((r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    r.first,
                                    style: theme.labelSmall.override(
                                      color: theme.secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: SelectableText(
                                    r.last,
                                    textAlign: TextAlign.end,
                                    style: theme.bodySmall.override(
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

// â”€â”€ Source Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.source,
    required this.value,
    required this.useCase,
  });

  final IconData icon;
  final String source;
  final String value;
  final String useCase;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.0, color: theme.primary),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source,
                  style: theme.titleSmall.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(value,
                    style: theme.bodyMedium.override(letterSpacing: 0.0)),
                const SizedBox(height: 2.0),
                Text(
                  useCase,
                  style: theme.labelMedium.override(
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Lead Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _LeadCard extends StatelessWidget {
  const _LeadCard({
    required this.name,
    required this.website,
    required this.city,
    required this.nace,
    required this.legalForm,
    required this.fitReason,
    required this.scoreBand,
    required this.scoreValue,
    required this.source,
  });

  final String name;
  final String website;
  final String city;
  final String nace;
  final String legalForm;
  final String fitReason;
  final String scoreBand;
  final double scoreValue;
  final String source;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final Color badgeColor;
    switch (scoreBand.toUpperCase()) {
      case 'HIGH':
        badgeColor = Colors.green;
        break;
      case 'MEDIUM':
        badgeColor = Colors.orange;
        break;
      default:
        badgeColor = theme.secondaryText;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: scoreBand.toUpperCase() == 'HIGH'
              ? Colors.green.withValues(alpha: 0.35)
              : theme.alternate,
          width: scoreBand.toUpperCase() == 'HIGH' ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row â€” name + score badge
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.titleSmall.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  scoreBand.toUpperCase(),
                  style: theme.labelSmall.override(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          _kv(context, 'Νομική Μορφή', legalForm),
          _kv(context, 'Πόλη', city),
          _kv(context, 'Ιστότοπος', website),
          _kv(context, 'ΚΑΔ / NACE', nace),
          _kv(context, 'Score', '${(scoreValue * 100).toStringAsFixed(0)}%'),
          _kv(context, 'Πηγή', source),
          if (fitReason != '-') ...[
            const SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Text(
                'Σημείωση: $fitReason',
                style: theme.labelMedium.override(
                  color: Colors.amber.shade900,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String label, String value) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: theme.labelMedium
                  .override(color: theme.secondaryText, letterSpacing: 0.0),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.bodyMedium.override(letterSpacing: 0.0),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Empty States â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _EmptyLeadState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return _EmptyBox(
      theme: theme,
      message:
          'Δεν υπάρχουν leads ακόμα. Μόλις το Cloud Function σκοράρει εγγραφές από ΓΕΜΗ / gov.data.gr, θα εμφανιστούν εδώ κατηγοριοποιημένα ως High / Medium / Low.',
    );
  }
}

class _EmptyAlertState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return _EmptyBox(
      theme: theme,
      message:
          'Δεν έχουν σταλεί email alerts ακόμα. Μόλις εντοπιστεί HIGH lead, θα λάβεις αυτόματα email την ίδια ημέρα.',
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.theme, required this.message});
  final FlutterFlowTheme theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Text(
        message,
        style: theme.bodyMedium.override(letterSpacing: 0.0),
      ),
    );
  }
}
