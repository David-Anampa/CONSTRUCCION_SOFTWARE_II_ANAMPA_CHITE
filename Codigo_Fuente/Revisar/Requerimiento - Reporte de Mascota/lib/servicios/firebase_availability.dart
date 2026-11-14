import 'package:flutter/foundation.dart';

/// Indica si Firebase está disponible en esta plataforma.
/// En web no se inicializa automáticamente porque no hay configuración válida.
const bool firebaseAvailable = !kIsWeb;
