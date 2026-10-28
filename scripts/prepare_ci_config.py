"""Create compile-only Firebase placeholders in CI; never replace real config."""
import os
from pathlib import Path

if os.environ.get("CI") != "true":
    raise SystemExit("This helper only runs with CI=true. Configure local apps with FlutterFire.")

root = Path(__file__).resolve().parents[1]
source = """import 'package:firebase_core/firebase_core.dart';

// Compile-only placeholder. No production Firebase project is used by CI.
class DefaultFirebaseOptions {
  static const currentPlatform = FirebaseOptions(
    apiKey: 'ci-placeholder-not-a-real-key',
    appId: '1:123456789:android:ci',
    messagingSenderId: '123456789',
    projectId: 'demo-unimatch',
  );
}
"""
for app in ("unimatch_user", "unimatch_admin"):
    target = root / app / "lib" / "firebase_options.dart"
    if target.exists():
        print(f"Preserving existing configuration: {app}")
        continue
    target.write_text(source, encoding="utf-8")
    print(f"Created compile-only CI configuration: {app}")
