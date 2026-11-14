import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/usuario.dart';
import '../../servicios/firebase_availability.dart' as fb_avail;

class AdminVM extends ChangeNotifier {
  String _nombreAdmin = "Admin";
  String? _fotoAdmin;
  bool _datosCargados = false;

  String get nombreAdmin => _nombreAdmin;
  String? get fotoAdmin => _fotoAdmin;
  bool get datosCargados => _datosCargados;

  /// Cargar datos del admin desde Firestore
  Future<void> cargarDatosAdmin() async {
    if (!fb_avail.firebaseAvailable) {
      _datosCargados = true;
      notifyListeners();
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        final nombreCompleto = data["nombre"] ?? "Admin";
        final palabras = nombreCompleto.toString().trim().split(' ');

        _nombreAdmin = palabras.isNotEmpty ? palabras[0] : "Admin";
        _fotoAdmin = data["fotoPerfil"];
        _datosCargados = true;
        notifyListeners();
      }
    } catch (e) {
      _datosCargados = true;
      notifyListeners();
    }
  }

  /// Cerrar sesión del admin
  Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }
}
