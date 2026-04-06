# Safe Dependency Upgrade Plan

**73 packages with newer incompatible versions** are available.

## Strategy
Upgrade in waves by compatibility/risk tier:

### Wave 1: Low-Risk (no breaking changes expected)
- `meta`: 1.17.0 → 1.18.1 (patch)
- `test_api`: patch update
- `xml`: 6.5.0 → 6.6.1 (patch)
- `http`: 1.4.0 → 1.6.0 (minor; test thoroughly with API calls)

**Commands:**
```bash
flutter pub upgrade --major-versions meta xml http test_api
```

### Wave 2: Medium-Risk (minor versions, usually compatible)
- Firebase family: `firebase_core`, `firebase_auth`, `firebase_storage` (major; coordinate tests)
- `go_router`: 12.1.3 → 17.2.0 (breaking; requires route testing)
- Cloud Firestore: all variants
- Providers: `provider`, `go_router_platform_interface`

**Important:** Test navigation & Firebase initialization thoroughly after upgrading `go_router`.

**Commands (staggered):**
```bash
flutter pub upgrade --major-versions firebase_core firebase_auth firebase_storage
# Test, commit, then:
flutter pub upgrade --major-versions go_router cloud_firestore
# Full integration test
```

### Wave 3: UI/UX (can be upgraded anytime)
- `google_fonts`, `carousel_slider`, `dropdown_button2`
- `flutter_animate`, `flutter_native_splash`, `font_awesome_flutter`
- `page_transition`, `url_launcher*`, `share_plus*`
- `video_player*`, `file_picker`

```bash
flutter pub upgrade --major-versions google_fonts carousel_slider dropdown_button2 flutter_animate flutter_native_splash
```

### Wave 4: Platform-Specific (batch after Wave 2)
- All `_android`, `_ios`, `_platform_interface` packages

```bash
flutter pub upgrade --major-versions path_provider_android path_provider_foundation shared_preferences_android shared_preferences_foundation url_launcher_android url_launcher_ios video_player_android video_player_avfoundation
```

## Testing Checklist per Wave

- [ ] Build succeeds: `flutter run -d windows --debug`
- [ ] Android build: `flutter run -d android --debug`
- [ ] No runtime exceptions in debug
- [ ] Test affected feature (Firebase init, routing, UI)
- [ ] Hot reload works

## Rollback Plan
If any wave breaks:
```bash
flutter pub get  # Restore from pubspec.lock
# Or targeted revert:
flutter pub upgrade package_name --major-versions  # Back to last stable in pubspec.yaml constraints
```

---

**Estimated Timeline:** 1-2 hours per wave with testing.
**Recommendation:** Perform Wave 1 immediately, Wave 2-3 after full testing cycle.
