# Archivo       : android/app/proguard-rules.pro
# Proyecto      : SOSMASCOTA
# Autores       : David Anampa, Danilo Chite
# Fecha         : 13/11/2026
# Descripción   : Reglas de ProGuard/R8 para preservar clases de TensorFlow Lite y anotaciones en release.
# Se vincula con: android/app/build.gradle.kts y plugin tflite_flutter.

# --- TensorFlow Lite GPU (mantener clases necesarias) ---
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# --- TFLite Flutter plugin ---
-keep class org.tensorflow.lite.gpu.** { *; }
-keepclassmembers class * {
    @org.tensorflow.lite.** <fields>;
}

# --- Evitar remover clases usadas por reflexión ---
-keepattributes Signature
-keepattributes *Annotation*
