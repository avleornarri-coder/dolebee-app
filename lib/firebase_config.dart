import 'package:firebase_core/firebase_core.dart';

/// Connection details for the shop's Firebase project. While this is null
/// the app runs as an offline preview with a sample menu, as on the web.
///
/// To connect, replace null with the values from google-services.json:
///
/// ```dart
/// const FirebaseOptions? firebaseAndroidOptions = FirebaseOptions(
///   apiKey: '...',            // client > api_key > current_key
///   appId: '...',             // client > client_info > mobilesdk_app_id
///   messagingSenderId: '...', // project_info > project_number
///   projectId: '...',         // project_info > project_id
///   storageBucket: '...',     // project_info > storage_bucket
/// );
/// ```
const FirebaseOptions? firebaseAndroidOptions = null;
