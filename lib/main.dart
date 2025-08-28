import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:social_media_app/firebase_options.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Avoid hanging on web due to missing/placeholder reCAPTCHA site key
  if (kIsWeb) {
    const siteKey = String.fromEnvironment('RECAPTCHA_V3_SITE_KEY', defaultValue: '');
    if (siteKey.isNotEmpty) {
      await FirebaseAppCheck.instance
          .activate(webProvider: ReCaptchaV3Provider(siteKey));
    }
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  }
  runApp(MyApp());
}
