// /**
//  * Archivo/Clase : firebase_fakes.dart / FakeAuthPlatform, FakeFirestorePlatform, FakeUserPlatform
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Dobles de prueba en memoria para la capa de plataforma de Firebase Auth
//  *                 y Cloud Firestore, evitando modificar el código de producción en lib/.
//  * Se vincula con: - USA: cloud_firestore_platform_interface, firebase_auth_platform_interface,
//  *                   firebase_core y firebase_core_platform_interface.
//  *                 - ES USADO POR: req01_autenticacion_prueba_unitaria_test.dart,
//  *                   req02_registro_usuario_prueba_unitaria_test.dart y
//  *                   req03_recuperar_contrasena_prueba_unitaria_test.dart.
//  * Funcionamiento: Registra FakeAuthPlatform y FakeFirestorePlatform como implementaciones
//  *                 activas mediante iniciarFirebaseFake(), simulando cuentas, documentos y streams.
//  * Requerimiento : REQ01, REQ02, REQ03 (Infraestructura de pruebas unitarias aisladas)
//  */

// Dobles de prueba de la capa de plataforma de Firebase.
//
// LoginVM, RegistroVM, RecuperarVM y AuthWrapper usan directamente
// FirebaseAuth.instance / FirebaseFirestore.instance. Para probarlos SIN
// modificar lib/, se sustituyen las implementaciones de plataforma
// (FirebaseAuthPlatform y FirebaseFirestorePlatform) por versiones en memoria.
import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

/// Inicializa Firebase con mocks y registra las plataformas en memoria.
Future<void> iniciarFirebaseFake() async {
  setupFirebaseCoreMocks();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Ya inicializado en otro test del mismo isolate.
  }
  FirebaseAuthPlatform.instance = FakeAuthPlatform.instancia;
  FirebaseFirestorePlatform.instance = FakeFirestorePlatform.instancia;
}

// ───────────────────────────── AUTH ─────────────────────────────

class FakeUserPlatform extends UserPlatform {
  bool verificado;

  FakeUserPlatform(FirebaseAuthPlatform auth, String uid, String email,
      {this.verificado = true})
      : super(
          auth,
          _FakeMultiFactor(auth),
          InternalUserDetails(
            userInfo: InternalUserInfo(
              uid: uid,
              email: email,
              isAnonymous: false,
              isEmailVerified: verificado,
            ),
            providerData: [],
          ),
        );

  @override
  Future<void> reload() async {}

  @override
  Future<void> sendEmailVerification(
      [ActionCodeSettings? actionCodeSettings]) async {
    FakeAuthPlatform.instancia.verificacionesEnviadas.add(email!);
  }
}

class _FakeMultiFactor extends MultiFactorPlatform {
  _FakeMultiFactor(super.auth);
}

class FakeUserCredential extends UserCredentialPlatform {
  FakeUserCredential(FirebaseAuthPlatform auth, UserPlatform user)
      : super(auth: auth, user: user);
}

class FakeAuthPlatform extends FirebaseAuthPlatform {
  static final FakeAuthPlatform instancia = FakeAuthPlatform._();
  FakeAuthPlatform._() : super();

  /// Cuentas registradas: correo -> (clave, uid, verificado)
  final Map<String, _Cuenta> cuentas = {};
  final List<String> verificacionesEnviadas = [];
  final List<String> correosRecuperacion = [];
  FakeUserPlatform? _actual;
  final StreamController<UserPlatform?> _estado =
      StreamController<UserPlatform?>.broadcast();

  /// Código de error a lanzar en la siguiente operación de recuperación.
  String? errorRecuperacion;
  int cierresDeSesion = 0;

  void reiniciar() {
    cuentas.clear();
    verificacionesEnviadas.clear();
    correosRecuperacion.clear();
    errorRecuperacion = null;
    cierresDeSesion = 0;
    _actual = null;
  }

  void agregarCuenta(String correo, String clave, String uid,
      {bool verificado = true}) {
    cuentas[correo] = _Cuenta(clave, uid, verificado);
  }

  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseAuthPlatform setInitialValues({
    InternalUserDetails? currentUser,
    String? languageCode,
  }) =>
      this;

  @override
  UserPlatform? get currentUser => _actual;

  @override
  set currentUser(UserPlatform? user) => _actual = user as FakeUserPlatform?;

  @override
  Stream<UserPlatform?> authStateChanges() async* {
    yield _actual;
    yield* _estado.stream;
  }

  @override
  Stream<UserPlatform?> idTokenChanges() => authStateChanges();

  @override
  Stream<UserPlatform?> userChanges() => authStateChanges();

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
      String email, String password) async {
    final c = cuentas[email];
    if (c == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    if (c.clave != password) {
      throw FirebaseAuthException(code: 'wrong-password');
    }
    _actual = FakeUserPlatform(this, c.uid, email, verificado: c.verificado);
    _estado.add(_actual);
    return FakeUserCredential(this, _actual!);
  }

  @override
  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
      String email, String password) async {
    if (cuentas.containsKey(email)) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use by another account.',
      );
    }
    if (password.length < 6) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Password should be at least 6 characters',
      );
    }
    final uid = 'uid_${cuentas.length + 1}';
    cuentas[email] = _Cuenta(password, uid, false);
    _actual = FakeUserPlatform(this, uid, email, verificado: false);
    _estado.add(_actual);
    return FakeUserCredential(this, _actual!);
  }

  @override
  Future<void> sendPasswordResetEmail(String email,
      [ActionCodeSettings? actionCodeSettings]) async {
    if (errorRecuperacion != null) {
      throw FirebaseAuthException(code: errorRecuperacion!);
    }
    correosRecuperacion.add(email);
  }

  @override
  Future<void> signOut() async {
    cierresDeSesion++;
    _actual = null;
    _estado.add(null);
  }
}

class _Cuenta {
  final String clave;
  final String uid;
  final bool verificado;
  _Cuenta(this.clave, this.uid, this.verificado);
}

// ─────────────────────────── FIRESTORE ───────────────────────────

class FakeFirestorePlatform extends FirebaseFirestorePlatform {
  static final FakeFirestorePlatform instancia = FakeFirestorePlatform._();
  FakeFirestorePlatform._() : super(appInstance: null);

  final Map<String, Map<String, dynamic>> docs = {};
  final Map<String, StreamController<DocumentSnapshotPlatform>> _streams = {};

  void reiniciar() => docs.clear();

  void sembrar(String ruta, Map<String, dynamic> datos) {
    docs[ruta] = Map<String, dynamic>.from(datos);
    _emitir(ruta);
  }

  void _emitir(String ruta) {
    _streams[ruta]?.add(_snap(ruta));
  }

  DocumentSnapshotPlatform _snap(String ruta) => DocumentSnapshotPlatform(
        this,
        ruta,
        docs[ruta] == null ? null : Map<String?, Object?>.from(docs[ruta]!),
        InternalSnapshotMetadata(hasPendingWrites: false, isFromCache: false),
      );

  @override
  FirebaseFirestorePlatform delegateFor(
          {required FirebaseApp app, required String databaseId}) =>
      this;

  @override
  CollectionReferencePlatform collection(String collectionPath) =>
      _FakeColeccion(this, collectionPath);

  @override
  DocumentReferencePlatform doc(String documentPath) =>
      _FakeDocumento(this, documentPath);

  @override
  Settings get settings => const Settings();

  @override
  set settings(Settings settings) {}
}

class _FakeColeccion extends CollectionReferencePlatform {
  final FakeFirestorePlatform _fs;
  _FakeColeccion(this._fs, String path) : super(_fs, path);

  @override
  DocumentReferencePlatform doc([String? path]) =>
      _FakeDocumento(_fs, '${this.path}/${path ?? 'auto_id'}');
}

class _FakeDocumento extends DocumentReferencePlatform {
  final FakeFirestorePlatform _fs;
  _FakeDocumento(this._fs, String path) : super(_fs, path);

  @override
  Future<DocumentSnapshotPlatform> get(
          [GetOptions options = const GetOptions()]) async =>
      _fs._snap(path);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    final limpio = <String, dynamic>{};
    data.forEach((k, v) => limpio[k] = v);
    if (options?.merge == true && _fs.docs[path] != null) {
      _fs.docs[path]!.addAll(limpio);
    } else {
      _fs.docs[path] = limpio;
    }
    _fs._emitir(path);
  }

  @override
  Future<void> update(Map<FieldPath, dynamic> data) async {
    if (_fs.docs[path] == null) {
      throw FirebaseException(plugin: 'cloud_firestore', code: 'not-found');
    }
    data.forEach((k, v) => _fs.docs[path]![k.components.join('.')] = v);
    _fs._emitir(path);
  }

  @override
  Future<void> delete() async {
    _fs.docs.remove(path);
    _fs._emitir(path);
  }

  @override
  Stream<DocumentSnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    ListenSource listenSource = ListenSource.defaultSource,
  }) async* {
    yield _fs._snap(path);
    final ctrl = _fs._streams.putIfAbsent(
      path,
      () => StreamController<DocumentSnapshotPlatform>.broadcast(),
    );
    yield* ctrl.stream;
  }
}
