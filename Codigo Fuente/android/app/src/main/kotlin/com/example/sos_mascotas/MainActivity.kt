/**
 * Archivo/Clase : MainActivity.kt / MainActivity
 * Proyecto      : SOSMASCOTA
 * Autores       : David Anampa, Danilo Chite
 * Fecha         : 13/11/2026
 * Descripción   : Actividad principal de Android que aloja el motor y la vista raíz de
 *                 Flutter dentro del contenedor nativo de la aplicación SOS Mascota.
 * Se vincula con: - USA: io.flutter.embedding.android.FlutterActivity.
 *                 - ES USADO POR: AndroidManifest.xml (punto de arranque LAUNCHER en Android).
 * Funcionamiento: Hereda el ciclo de vida estándar de FlutterActivity para inicializar
 *                 el engine de Dart y los canales de plugins nativos en Android.
 * Requerimiento : RF-01 al RF-17 (Contenedor nativo Android de la aplicación)
 */
package com.sosmascota

import io.flutter.embedding.android.FlutterActivity

/**
 * Actividad de entrada principal en Android que hospeda la interfaz Flutter de SOS Mascota.
 */
class MainActivity : FlutterActivity()
