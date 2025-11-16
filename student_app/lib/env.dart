// lib/env.dart
export 'env_stub.dart'
  if (dart.library.io) 'env_io.dart'
  if (dart.library.html) 'env_web.dart';