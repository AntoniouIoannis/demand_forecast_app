import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

  String? _selectedMarket;
  String? _selectedCountry;
  int? _selectedForecastHorizonDays;

  @override
  void initState() {
    super.initState();
    _selectedMarket = FFAppState().selectedBusinessMarket;
    _selectedCountry = FFAppState().selectedMarketCountry;
    _selectedForecastHorizonDays = FFAppState().forecastHorizonDays;
  }

  void _onProfileSelectionChanged() {
    FFAppState().update(() {
      FFAppState().selectedBusinessMarket = _selectedMarket;
      FFAppState().selectedMarketCountry = _selectedCountry;
      FFAppState().forecastHorizonDays = _selectedForecastHorizonDays;
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('onhold_users')
          .doc(uid)
          .set(<String, dynamic>{
        'market': _selectedMarket,
        'marketCountry': _selectedCountry,
        'forecastHorizonDays': _selectedForecastHorizonDays,
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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
            'Business Market',
            style: GoogleFonts.inter(
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6.0),
          DropdownButtonFormField<String>(
            value: _selectedMarket,
            items: _businessMarkets
                .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                .toList(),
            onChanged: (val) {
              setState(() => _selectedMarket = val);
              _onProfileSelectionChanged();
            },
            decoration: InputDecoration(
              hintText: 'Choose market',
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
            value: _selectedCountry,
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
            value: _selectedForecastHorizonDays,
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
                          .withOpacity(0.15),
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
                    _StatusChip(plan: appState.subscriptionPlan),
                  ],
                ),
              ),

              const SizedBox(height: 28.0),

              // ─── Account Details ──────────────────────────────────────
              _SectionHeader(title: 'Account Details'),
              const SizedBox(height: 12.0),

              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: currentUserEmail.isNotEmpty
                    ? currentUserEmail
                    : '(not set)',
              ),
              const SizedBox(height: 10.0),

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
            ? FlutterFlowTheme.of(context).primary.withOpacity(0.12)
            : FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isPro
              ? FlutterFlowTheme.of(context).primary.withOpacity(0.4)
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
