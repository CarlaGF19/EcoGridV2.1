import 'dart:html' as html;

bool isAndroidWeb() {
  final ua = (windowNavigatorUserAgent()).toLowerCase();
  return ua.contains('android');
}

// Wrapper to avoid direct dart:html import in consumer files
String windowNavigatorUserAgent() {
  // Use dart:html only inside web implementation
  // ignore: avoid_web_libraries_in_flutter
  return (dartHtmlWindowNavigatorUserAgent());
}

// ignore: avoid_web_libraries_in_flutter
String dartHtmlWindowNavigatorUserAgent() => (html.window.navigator.userAgent);

// web import moved to top
