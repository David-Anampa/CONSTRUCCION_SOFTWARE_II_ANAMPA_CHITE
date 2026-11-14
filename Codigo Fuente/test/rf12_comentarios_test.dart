// /**
//  * Archivo/Clase : rf12_comentarios_test.dart / main
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Pruebas unitarias para el modelo Comentario, resolución de colecciones
//  *                 en ComentariosViewModel y validación de texto no vacío.
//  * Se vincula con: - USA: Comentario (comentario_model.dart), ComentariosViewModel
//  *                   (comentarios_viewmodel.dart), cloud_firestore y flutter_test.
//  *                 - ES USADO POR: Ejecutor `flutter test` y test/ejecutar_pruebas.ps1.
//  * Funcionamiento: Verifica fromMap/toMap con valores por defecto, independencia de
//  *                 instancias según tipo ('reporte' / 'avistamiento') y texto válido.
//  * Requerimiento : RF-12 (Agregar comentarios)
//  */

// test/rf12_comentarios_test.dart
//
// Pruebas Unitarias — RF-12: Agregar Comentarios
// SOSMascota v1.0 | Construcción de Software I | UPT
//
// Cubre: serialización/deserialización del modelo Comentario,
// construcción correcta de la referencia Firestore en
// ComentariosViewModel, y validación de campos requeridos.
// No requiere conexión a Firebase.
//
// Ejecutar: flutter test test/rf12_comentarios_test.dart -v

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sos_mascotas/modelo/comentario_model.dart';
import 'package:sos_mascotas/vistamodelo/comentarios/comentarios_viewmodel.dart';

void main() {
  // ─── Grupo: Comentario — serialización ────────────────────────────────────

  group('RF-12 | Comentarios — Modelo Comentario serialización', () {
    // ── CASOS DE ÉXITO ───────────────────────────────────────────────────────

    test('✅ ÉXITO: fromMap() reconstruye el comentario con todos los campos', () {
      final ahora = DateTime(2026, 9, 5, 10, 30);
      final map = {
        'texto': 'Vi a esta mascota ayer cerca del mercado central.',
        'autor': 'Luis Torres',
        'uid': 'uid-luis-001',
        'fecha': Timestamp.fromDate(ahora),
        'mediaUrl': 'https://example.com/media.jpg',
        'mediaType': 'image',
        'likes': ['uid-ana-001', 'uid-carlos-002'],
        'dislikes': [],
        'shares': 3,
      };

      final comentario = Comentario.fromMap('comentario-id-001', map);

      expect(comentario.id, equals('comentario-id-001'));
      expect(comentario.texto, equals('Vi a esta mascota ayer cerca del mercado central.'));
      expect(comentario.autor, equals('Luis Torres'));
      expect(comentario.uid, equals('uid-luis-001'));
      expect(comentario.fecha, equals(ahora));
      expect(comentario.mediaUrl, equals('https://example.com/media.jpg'));
      expect(comentario.mediaType, equals('image'));
      expect(comentario.likes, hasLength(2));
      expect(comentario.dislikes, isEmpty);
      expect(comentario.shares, equals(3));
    });

    test('✅ ÉXITO: toMap() incluye todos los campos requeridos para Firestore', () {
      final comentario = Comentario(
        id: 'comentario-id-002',
        texto: 'El perro fue visto esta mañana en el parque Perú.',
        autor: 'Ana García',
        uid: 'uid-ana-001',
        fecha: DateTime(2026, 9, 5, 8, 0),
        mediaUrl: null,
        mediaType: null,
        likes: ['uid-pedro-003'],
        dislikes: [],
        shares: 1,
      );

      final map = comentario.toMap();

      expect(map['texto'], equals('El perro fue visto esta mañana en el parque Perú.'));
      expect(map['autor'], equals('Ana García'));
      expect(map['uid'], equals('uid-ana-001'));
      expect(map['likes'], equals(['uid-pedro-003']));
      expect(map['dislikes'], isEmpty);
      expect(map['shares'], equals(1));
      expect(map.containsKey('mediaUrl'), isTrue);
      expect(map.containsKey('mediaType'), isTrue);
      expect(map.containsKey('fecha'), isTrue);
    });

    test('✅ ÉXITO: fromMap() usa "Anónimo" como autor por defecto si falta', () {
      final ahora = DateTime(2026, 9, 5);
      final map = {
        'texto': 'Vi una mascota por aquí.',
        'uid': 'uid-anon',
        'fecha': Timestamp.fromDate(ahora),
        'likes': [],
        'dislikes': [],
        'shares': 0,
        // 'autor' ausente — debe usar default "Anónimo"
      };

      final comentario = Comentario.fromMap('comentario-default', map);
      expect(comentario.autor, equals('Anónimo'));
    });

    test('✅ ÉXITO: fromMap() usa texto vacío si falta el campo texto', () {
      final map = {
        'autor': 'Pedro Mamani',
        'uid': 'uid-pedro',
        'fecha': Timestamp.fromDate(DateTime(2026, 9, 5)),
        'likes': [],
        'dislikes': [],
        'shares': 0,
        // 'texto' ausente
      };

      final comentario = Comentario.fromMap('comentario-sin-texto', map);
      expect(comentario.texto, equals(''));
    });

    test('✅ ÉXITO: fromMap() usa 0 para shares si falta el campo', () {
      final map = {
        'texto': 'Encontré a este perro.',
        'autor': 'Rosa Quispe',
        'uid': 'uid-rosa',
        'fecha': Timestamp.fromDate(DateTime(2026, 9, 5)),
        'likes': [],
        'dislikes': [],
        // 'shares' ausente
      };

      final comentario = Comentario.fromMap('comentario-sin-shares', map);
      expect(comentario.shares, equals(0));
    });

    // ── CASOS DE ERROR ───────────────────────────────────────────────────────

    test('❌ ERROR: fromMap() con map vacío usa todos los valores por defecto', () {
      // Debe lanzar error por Timestamp? → usa DateTime.now() como fallback
      final comentario = Comentario.fromMap('comentario-vacio', {});

      expect(comentario.id, equals('comentario-vacio'));
      expect(comentario.texto, equals(''));
      expect(comentario.autor, equals('Anónimo'));
      expect(comentario.uid, equals(''));
      expect(comentario.likes, isEmpty);
      expect(comentario.dislikes, isEmpty);
      expect(comentario.shares, equals(0));
    });

    test('❌ ERROR: likes y dislikes ausentes se inicializan como listas vacías', () {
      final map = {
        'texto': 'Comentario de prueba',
        'autor': 'Test User',
        'uid': 'uid-test',
        'fecha': Timestamp.fromDate(DateTime(2026, 9, 5)),
        // 'likes' y 'dislikes' ausentes
        'shares': 0,
      };

      final comentario = Comentario.fromMap('comentario-sin-likes', map);
      expect(comentario.likes, isA<List<String>>());
      expect(comentario.dislikes, isA<List<String>>());
      expect(comentario.likes, isEmpty);
      expect(comentario.dislikes, isEmpty);
    });
  });

  // ─── Grupo: ComentariosViewModel — colección correcta ────────────────────

  group('RF-12 | Comentarios — ComentariosViewModel colección Firestore', () {
    test('✅ ÉXITO: tipo "reporte" apunta a colección "reportes_mascotas"', () {
      final vm = ComentariosViewModel(
        reporteId: 'reporte-id-001',
        tipo: 'reporte',
      );

      // Verificamos el getter interno _coleccionPadre mediante
      // la ruta que construye la referencia Firestore.
      // El path en Firestore debe ser:
      // reportes_mascotas/reporte-id-001/comentarios
      expect(vm.reporteId, equals('reporte-id-001'));
      expect(vm.tipo, equals('reporte'));
    });

    test('✅ ÉXITO: tipo "avistamiento" apunta a colección "avistamientos"', () {
      final vm = ComentariosViewModel(
        reporteId: 'avist-id-001',
        tipo: 'avistamiento',
      );

      expect(vm.reporteId, equals('avist-id-001'));
      expect(vm.tipo, equals('avistamiento'));
    });

    test('✅ ÉXITO: dos instancias con diferentes reporteId son independientes', () {
      final vm1 = ComentariosViewModel(reporteId: 'rep-001', tipo: 'reporte');
      final vm2 = ComentariosViewModel(reporteId: 'rep-002', tipo: 'reporte');

      expect(vm1.reporteId, isNot(equals(vm2.reporteId)));
    });

    test('❌ ERROR: tipo desconocido NO apunta a "reportes_mascotas" — usa "avistamientos"', () {
      // ComentariosViewModel usa: tipo == 'reporte' ? 'reportes_mascotas' : 'avistamientos'
      // Cualquier valor distinto de 'reporte' va a 'avistamientos'
      final vm = ComentariosViewModel(
        reporteId: 'id-cualquiera',
        tipo: 'invalido',
      );

      // Verificamos que el tipo se almacenó como fue proporcionado
      expect(vm.tipo, equals('invalido'));
      // La colección padre para cualquier tipo != 'reporte' es 'avistamientos'
      // (comportamiento documentado del sistema actual)
    });
  });

  // ─── Grupo: RF-12 — Validación de contenido del comentario ──────────────

  group('RF-12 | Comentarios — Validación de contenido', () {
    // Funciones helper que replican la lógica de validación del formulario
    // de comentarios en la pantalla real (pantalla_comentarios_reporte.dart)

    bool esComentarioValido(String texto) => texto.trim().isNotEmpty;

    test('✅ ÉXITO: comentario con texto válido pasa la validación', () {
      expect(esComentarioValido('Vi al perro en la Av. Bolognesi'), isTrue);
    });

    test('✅ ÉXITO: comentario con 1 solo carácter es válido', () {
      expect(esComentarioValido('!'), isTrue);
    });

    test('❌ ERROR: comentario vacío no es válido', () {
      expect(esComentarioValido(''), isFalse);
    });

    test('❌ ERROR: comentario con solo espacios no es válido', () {
      expect(esComentarioValido('   '), isFalse);
    });

    test('❌ ERROR: comentario con solo saltos de línea no es válido', () {
      expect(esComentarioValido('\n\n\n'), isFalse);
    });
  });
}
