import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key});

  static String routeName = 'UserProfile';
  static String routePath = 'userProfile';

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  bool _tokenVisible = false;
  bool _sendingReset = false;
  StreamSubscription<User?>? _authSub;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _websiteController;

  static const List<String> _businessMarkets = <String>[
    'Retail',
    'Food & Beverage',
    'Pharmacy',
    'Electronics',
    'Fashion',
    'Automotive',
    'Hospitality',
    'Other',
  ];
  static const List<String> _marketCountries = <String>[
    'Greece',
    'Cyprus',
    'Italy',
    'Germany',
    'France',
    'Spain',
    'United Kingdom',
    'United States',
  ];
  static const List<int> _forecastHorizons = <int>[30, 90, 365];
  static const List<String> _seasonalCalendars = <String>[
    'General Retail Calendar',
    'Tourism & Hospitality Calendar',
    'Food & Beverage Calendar',
    'Fashion & Apparel Calendar',
    'Pharmacy & Wellness Calendar',
  ];
  static const List<String> _naceCodes = <String>[
    '47.19 - Other retail sale in non-specialised stores',
    '47.54 - Retail sale of electrical household appliances',
    '46.43 - Wholesale of electrical household appliances',
    '47.91 - Retail sale via mail order houses or via Internet',
    '56.10 - Restaurants and mobile food service activities',
  ];

  String? _selectedMarket;
  String? _selectedCountry;
  int? _selectedForecastHorizonDays;
  String? _selectedSeasonalCalendar;
  String? _selectedNaceCode;

  String _cacheKey(String uid) => 'user_profile_cache_$uid';

  String? _asStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  int? _asIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _websiteController = TextEditingController();
    _selectedMarket = FFAppState().selectedBusinessMarket;
    _selectedCountry = FFAppState().selectedMarketCountry;
    _selectedForecastHorizonDays = FFAppState().forecastHorizonDays;
    _bootstrapProfileHydration();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final uid = user?.uid;
      if (uid == null || uid.isEmpty) return;
      _hydrateProfileFromLocal(uid);
      _hydrateProfileFromFirestore(uid: uid);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapProfileHydration() async {
    var uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      try {
        final user = await FirebaseAuth.instance
            .authStateChanges()
            .firstWhere((u) => u != null)
            .timeout(const Duration(seconds: 4));
        uid = user?.uid;
      } catch (_) {
        uid = null;
      }
    }

    if (uid == null || uid.isEmpty) return;
    await _hydrateProfileFromLocal(uid);
    await _hydrateProfileFromFirestore(uid: uid);
  }

  void _applyProfileData(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      _firstNameController.text = _asStringOrNull(data['firstName']) ?? '';
      _lastNameController.text = _asStringOrNull(data['lastName']) ?? '';
      _websiteController.text = _asStringOrNull(data['website']) ?? '';
      _selectedSeasonalCalendar = _asStringOrNull(data['seasonalCalendar']);
      _selectedNaceCode = _asStringOrNull(data['naceCode']);
      _selectedMarket =
          _asStringOrNull(data['productCategory'] ?? data['market']) ??
              _selectedMarket;
      _selectedCountry =
          _asStringOrNull(data['marketCountry']) ?? _selectedCountry;
      _selectedForecastHorizonDays =
          _asIntOrNull(data['forecastHorizonDays']) ??
              _selectedForecastHorizonDays;
    });
  }

  Future<void> _hydrateProfileFromLocal(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey(uid));
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _applyProfileData(decoded);
      }
    } catch (_) {
      // Ignore local cache errors.
    }
  }

  Future<void> _hydrateProfileFromFirestore({String? uid}) async {
    final resolvedUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolvedUid == null || resolvedUid.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('onhold_users')
          .doc(resolvedUid)
          .get();
      if (!doc.exists) return;

      final data = doc.data() ?? <String, dynamic>{};
      _applyProfileData(data);
      await _saveProfileToLocal(resolvedUid, data);
    } on FirebaseException {
      // Keep the existing local state when profile hydration fails.
    } on TypeError {
      // Ignore incompatible field types and keep UI responsive.
    }
  }

  Future<void> _saveProfileToLocal(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey(uid), jsonEncode(data));
    } catch (_) {
      // Ignore local cache write failures.
    }
  }

  Map<String, dynamic> _currentProfilePayload() {
    return <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'website': _websiteController.text.trim(),
      'productCategory': _selectedMarket,
      'market': _selectedMarket,
      'marketCountry': _selectedCountry,
      'forecastHorizonDays': _selectedForecastHorizonDays,
      'seasonalCalendar': _selectedSeasonalCalendar,
      'naceCode': _selectedNaceCode,
      'profileStage': 'completed_profile',
      'lastSeenAt': FieldValue.serverTimestamp(),
    };
  }

  void _onProfileSelectionChanged() {
    FFAppState().update(() {
      FFAppState().selectedBusinessMarket = _selectedMarket;
      FFAppState().selectedMarketCountry = _selectedCountry;
      FFAppState().forecastHorizonDays = _selectedForecastHorizonDays;
    });
    _saveProfile();
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      final payload = _currentProfilePayload();
      await _saveProfileToLocal(uid, payload);
      await FirebaseFirestore.instance
          .collection('onhold_users')
          .doc(uid)
          .set(payload, SetOptions(merge: true));
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_sendingReset) return;
    final email = currentUserEmail;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email associated with this account.')),
      );
      return;
    }
    setState(() => _sendingReset = true);
    try {
      await authManager.resetPassword(email: email, context: context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to send reset email. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingReset = false);
    }
  }

  Future<void> _signOut() async {
    await authManager.signOut();
    if (mounted) {
      context.goNamed(Auth2Widget.routeName);
    }
  }

  Widget _buildBusinessContextPanel(BuildContext ctx) {
    final theme = FlutterFlowTheme.of(ctx);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First Name',
            style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          TextFormField(
            controller: _firstNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter first name',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onChanged: (_) => _saveProfile(),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Last Name',
            style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          TextFormField(
            controller: _lastNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter last name',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onChanged: (_) => _saveProfile(),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Business Website',
            style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          TextFormField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://example.gr',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onChanged: (_) => _saveProfile(),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Product Category',
            style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<String>(
<<<<<<< HEAD
            key: const ValueKey('market_dropdown'),
=======
>>>>>>> 2b1a5b8a46b5371e3889d6df21232140e92b0b78
            initialValue: _selectedMarket,
            items: _businessMarkets
                .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedMarket = val);
              _onProfileSelectionChanged();
            },
            decoration: InputDecoration(
              hintText: 'Choose product category',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Seasonal Calendar',
            style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<String>(
            key: const ValueKey('seasonal_calendar_dropdown'),
            initialValue: _selectedSeasonalCalendar,
            items: _seasonalCalendars
                .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedSeasonalCalendar = val);
              _onProfileSelectionChanged();
            },
            decoration: InputDecoration(
              hintText: 'Select seasonal calendar',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'NACE / KAD Focus',
            style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<String>(
            key: const ValueKey('nace_dropdown'),
            initialValue: _selectedNaceCode,
            items: _naceCodes
                .map((n) => DropdownMenuItem<String>(value: n, child: Text(n)))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedNaceCode = val);
              _onProfileSelectionChanged();
            },
            decoration: InputDecoration(
              hintText: 'Select NACE/KAD code',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Market Country',
            style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<String>(
<<<<<<< HEAD
            key: const ValueKey('country_dropdown'),
=======
>>>>>>> 2b1a5b8a46b5371e3889d6df21232140e92b0b78
            initialValue: _selectedCountry,
            items: _marketCountries
                .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedCountry = val);
              _onProfileSelectionChanged();
            },
            decoration: InputDecoration(
              hintText: 'Choose country',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Forecast Horizon',
            style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<int>(
<<<<<<< HEAD
            key: const ValueKey('forecast_horizon_dropdown'),
=======
>>>>>>> 2b1a5b8a46b5371e3889d6df21232140e92b0b78
            initialValue: _selectedForecastHorizonDays,
            items: _forecastHorizons
                .map((d) =>
                    DropdownMenuItem<int>(value: d, child: Text('$d days')))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedForecastHorizonDays = val);
              _onProfileSelectionChanged();
            },
            decoration: InputDecoration(
              hintText: 'Select horizon',
              filled: true,
              fillColor: theme.primaryBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              Expanded(
                child: FFButtonWidget(
                  onPressed: _saveProfile,
                  text: 'Save SME Profile',
                  options: FFButtonOptions(
                    height: 44.0,
                    color: theme.primary,
                    textStyle: theme.titleSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w600,
                      ),
                      color: theme.info,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    elevation: 0.0,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: FFButtonWidget(
                  onPressed: () {
                    unawaited(_saveProfile().catchError((_) {}));
                    context.pushNamed(RadarWidget.routeName);
                  },
                  text: 'Open Radar',
                  icon: const Icon(Icons.radar_rounded, size: 18.0),
                  options: FFButtonOptions(
                    height: 44.0,
                    color: theme.secondaryBackground,
                    textStyle: theme.titleSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w600,
                      ),
                      color: theme.primary,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: theme.primary, width: 1.0),
                    elevation: 0.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = FFAppState();
    final remaining =
        (appState.monthlyTokenLimit - appState.usedTokensThisMonth)
            .clamp(0, 999999);
    final tokenUsageFraction = appState.monthlyTokenLimit == 0
        ? 0.0
        : (appState.usedTokensThisMonth / appState.monthlyTokenLimit)
            .clamp(0.0, 1.0);
    final jwtShort = currentJwtToken.isEmpty
        ? '(not available)'
        : currentJwtToken.length > 40
            ? '${currentJwtToken.substring(0, 40)}…'
            : currentJwtToken;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: FlutterFlowTheme.of(context).info),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'My Profile',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).info,
                letterSpacing: 0.0,
              ),
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Avatar + display name ────────────────────────────────
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: FlutterFlowTheme.of(context)
                          .primary
                          .withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person_rounded,
                        size: 44.0,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      currentUserDisplayName.isNotEmpty
                          ? currentUserDisplayName
                          : 'User',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .fontWeight,
                            ),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      currentUserEmail.isNotEmpty
                          ? currentUserEmail
                          : '(email not set)',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    _StatusChip(plan: appState.subscriptionPlan),
                  ],
                ),
              ),

              const SizedBox(height: 28.0),

              // ─── Account Details ──────────────────────────────────────
              _SectionHeader(title: 'Account Details'),
              const SizedBox(height: 12.0),

              _InfoTile(
                icon: Icons.lock_outline_rounded,
                label: 'Password',
                value: '••••••••',
                trailing: TextButton(
                  onPressed: _sendingReset ? null : _sendPasswordReset,
                  child: Text(
                    _sendingReset ? 'Sending…' : 'Reset',
                    style: TextStyle(
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // ─── Subscription ─────────────────────────────────────────
              _SectionHeader(title: 'Subscription'),
              const SizedBox(height: 12.0),

              _InfoTile(
                icon: Icons.workspace_premium_outlined,
                label: 'Plan',
                value: appState.subscriptionPlan,
              ),
              const SizedBox(height: 10.0),

              // Token usage row
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.token_outlined,
                            size: 20.0,
                            color: FlutterFlowTheme.of(context).secondaryText),
                        const SizedBox(width: 10.0),
                        Text(
                          'Tokens',
                          style: FlutterFlowTheme.of(context)
                              .labelMedium
                              .override(letterSpacing: 0.0),
                        ),
                        const Spacer(),
                        Text(
                          '${appState.usedTokensThisMonth} / ${appState.monthlyTokenLimit}',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999.0),
                      child: LinearProgressIndicator(
                        value: tokenUsageFraction,
                        minHeight: 7.0,
                        backgroundColor: FlutterFlowTheme.of(context).alternate,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          tokenUsageFraction >= 0.9
                              ? Colors.redAccent
                              : FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '$remaining tokens remaining this month',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // ─── JWT Token ────────────────────────────────────────────
              _SectionHeader(title: 'Session Token (JWT)'),
              const SizedBox(height: 12.0),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.vpn_key_outlined,
                            size: 20.0,
                            color: FlutterFlowTheme.of(context).secondaryText),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            _tokenVisible ? currentJwtToken : jwtShort,
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.robotoMono(),
                                      letterSpacing: 0.0,
                                    ),
                            maxLines: _tokenVisible ? null : 2,
                            overflow: _tokenVisible
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _tokenVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          onPressed: () =>
                              setState(() => _tokenVisible = !_tokenVisible),
                          tooltip: _tokenVisible ? 'Hide' : 'Show full token',
                        ),
                      ],
                    ),
                    if (_tokenVisible && currentJwtToken.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              // copy to clipboard
                              final data = ClipboardData(text: currentJwtToken);
                              Clipboard.setData(data);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Token copied to clipboard.')),
                              );
                            },
                            icon: const Icon(Icons.copy_outlined, size: 16.0),
                            label: const Text('Copy'),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // ─── Business Context ─────────────────────────────────────
              _SectionHeader(title: 'Business Context'),
              const SizedBox(height: 12.0),
              _buildBusinessContextPanel(context),

              const SizedBox(height: 40.0),

              // ─── Sign Out ─────────────────────────────────────────────
              FFButtonWidget(
                onPressed: _signOut,
                text: 'Sign Out',
                icon: const Icon(Icons.logout_rounded, size: 18.0),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 50.0,
                  color: Colors.redAccent,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w600,
                        ),
                        color: Colors.white,
                        letterSpacing: 0.0,
                      ),
                  borderRadius: BorderRadius.circular(12.0),
                  elevation: 0.0,
                ),
              ),

              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: FlutterFlowTheme.of(context).labelSmall.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
            color: FlutterFlowTheme.of(context).secondaryText,
            letterSpacing: 1.2,
          ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 20.0, color: FlutterFlowTheme.of(context).secondaryText),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.plan});
  final String plan;

  @override
  Widget build(BuildContext context) {
    final bool isPro =
        plan.toLowerCase() != 'freemium' && plan.toLowerCase() != 'free';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isPro
            ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.12)
            : FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isPro
              ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.4)
              : FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: Text(
        plan,
        style: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
              color: isPro
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
      ),
    );
  }
}
