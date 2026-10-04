# 🐾 SOS Mascota — Construcción de Software II

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Estado-En%20Desarrollo-brightgreen?style=for-the-badge"/>
</p>

<p align="center">
  <strong>Aplicación móvil para reportar y encontrar mascotas perdidas en la ciudad de Tacna, Perú.</strong>
</p>

---

## 📋 Información del Proyecto

| Campo             | Detalle                                         |
|-------------------|-------------------------------------------------|
| **Curso**         | Construcción de Software II                     |
| **Grupo**         | G04                                             |
| **Integrante**    | David Anampa Chite                              |
| **Universidad**   | Universidad Privada de Tacna (UPT)              |
| **Semestre**      | 2026 - II                                       |
| **Rama activa**   | `UNIDAD-I`                                      |

---

## 🚀 Descripción General

**SOS Mascota** es una aplicación móvil multiplataforma desarrollada con **Flutter** y **Firebase** que permite a los ciudadanos de Tacna:

- 📢 **Reportar** mascotas perdidas con foto, descripción y ubicación GPS.
- 🔍 **Buscar** y **avistar** mascotas en la zona con mapa interactivo.
- 🤖 **Identificar** razas de animales mediante un modelo de IA con TensorFlow Lite.
- 🔔 **Recibir notificaciones** push cuando hay coincidencias cercanas.
- 📄 **Generar reportes** en PDF y compartirlos.
- 🔐 **Autenticarse** con correo/contraseña o cuenta de Google.
- 📷 **Escanear códigos QR** para identificación rápida de mascotas.

---

## 🗂️ Estructura del Repositorio

```
📦 CONSTRUCCION_SOFTWARE_II_ANAMPA_CHITE/
├── 📁 Código Fuente/                          # Proyecto Flutter completo (SOS Mascotas)
│   ├── lib/
│   │   ├── main.dart                          # Punto de entrada de la app
│   │   ├── app.dart                           # Configuración de rutas y tema
│   │   ├── modelo/                            # Modelos de datos (Mascota, Usuario, etc.)
│   │   ├── vista/                             # Pantallas y vistas de la UI
│   │   ├── vistamodelo/                       # ViewModels (patrón MVVM)
│   │   ├── servicios/                         # Servicios Firebase, notificaciones, IA
│   │   ├── widgets/                           # Componentes reutilizables
│   │   └── utils/                             # Utilidades y helpers
│   ├── assets/                                # Recursos (imágenes, modelos IA, videos)
│   ├── pubspec.yaml                           # Dependencias Flutter
│   └── firestore.rules                        # Reglas de seguridad Firestore
│
├── 📁 Especificaciones funcionales/           # Documentación de requisitos
│   ├── G04_Lab.02_Especificaciones_Funcionales.pdf
│   └── G04_Trazabilidad Implementación.xlsx
│
├── 📁 Plan de iteración/                      # Planificación Scrum / Sprints
│   ├── G03-Planificacion de Sprints Backlogs.pdf
│   └── G04_Plan de Iteración.pdf
│
├── 📁 Casos de prueba_&_Catálogo de pruebas/  # Pruebas y catálogo QA
│   ├── G04-Catalogo_de_Casos_de_Prueba_v5.xlsx
│   ├── G04_Casos de Prueba.pdf
│   └── G04_Lab.03_Casos de Prueba _ Catalogo de prueba.pdf
│
├── 📁 Revisión de Código/                     # Informes de revisión de código
│   └── G0X_Lab.01 - Revisión de Código.pdf
│
└── 📁 Laboratorios y sus respectivas evidencias/
    └── Informe_Ejecutivo_SOSMascota.pdf
```

---

## 🏗️ Arquitectura

El proyecto sigue el patrón **MVVM (Model-View-ViewModel)** con las siguientes capas:

```
┌─────────────────────────────────────────────────────┐
│                    VISTA (UI)                        │
│         Flutter Widgets / Screens                    │
└──────────────────────┬──────────────────────────────┘
                       │ observa / notifica
┌──────────────────────▼──────────────────────────────┐
│               VISTA-MODELO (ViewModel)               │
│          Provider / ChangeNotifier                   │
└──────────────────────┬──────────────────────────────┘
                       │ llama
┌──────────────────────▼──────────────────────────────┐
│               MODELO & SERVICIOS                     │
│    Firebase Auth · Firestore · Storage · FCM · IA   │
└─────────────────────────────────────────────────────┘
```

---

## 🛠️ Tecnologías y Dependencias Principales

| Tecnología / Paquete        | Uso                                     |
|-----------------------------|-----------------------------------------|
| `flutter` + `dart`          | Framework principal multiplataforma     |
| `firebase_auth`             | Autenticación de usuarios               |
| `cloud_firestore`           | Base de datos en tiempo real            |
| `firebase_storage`          | Almacenamiento de imágenes y videos     |
| `firebase_messaging`        | Notificaciones push (FCM)               |
| `firebase_app_check`        | Seguridad y protección de la app        |
| `tflite_flutter`            | Modelo de IA para reconocimiento animal |
| `flutter_map` + `latlong2`  | Mapa interactivo con ubicación GPS      |
| `image_picker`              | Captura de fotos desde cámara/galería   |
| `mobile_scanner`            | Lectura de códigos QR                   |
| `qr_flutter`                | Generación de códigos QR                |
| `pdf`                       | Generación de reportes en PDF           |
| `google_sign_in`            | Inicio de sesión con Google             |
| `share_plus`                | Compartir reportes en redes sociales    |
| `lottie`                    | Animaciones vectoriales                 |
| `provider`                  | Gestión de estado                       |

---

## 📌 Ramas del Repositorio

| Rama         | Contenido                                              |
|--------------|--------------------------------------------------------|
| `UNIDAD-I`   | ✅ Rama principal — Todo el contenido del proyecto     |
| `UNIDAD-II`  | 🔄 Reservada para avances de la segunda unidad        |
| `UNIDAD-III` | 🔄 Reservada para avances de la tercera unidad        |
| `main`       | Rama base del repositorio                              |

---

## ⚙️ Instalación y Ejecución

### Pre-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `^3.8.1`
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Cuenta de Firebase configurada con el proyecto

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/David-Anampa/CONSTRUCCION_SOFTWARE_II_ANAMPA_CHITE.git
cd CONSTRUCCION_SOFTWARE_II_ANAMPA_CHITE

# 2. Cambiar a la rama UNIDAD-I
git checkout UNIDAD-I

# 3. Ingresar al código fuente
cd "Código Fuente"

# 4. Instalar dependencias
flutter pub get

# 5. Ejecutar la aplicación
flutter run
```

---

## 🧪 Pruebas

```bash
# Ejecutar pruebas unitarias
flutter test

# Pruebas con cobertura
flutter test --coverage
```

Los casos de prueba documentados se encuentran en la carpeta `Casos de prueba_&_Catálogo de pruebas/`.

---

## 📄 Documentación

| Documento                              | Descripción                              |
|----------------------------------------|------------------------------------------|
| Especificaciones Funcionales           | Requisitos funcionales y trazabilidad    |
| Plan de Iteración / Sprints            | Planificación ágil del desarrollo        |
| Catálogo de Casos de Prueba            | Escenarios y resultados de pruebas QA    |
| Revisión de Código                     | Análisis y feedback del código fuente    |
| Informe Ejecutivo                      | Resumen ejecutivo del proyecto           |

---

## 👤 Autores

**David Anampa**  
**Danilo Chite**  
Estudiante de Ingeniería de Sistemas — Universidad Privada de Tacna  
📧 GitHub: [@David-Anampa](https://github.com/David-Anampa)
📧 GitHub: [@Danilo314](https://github.com/Danilo314))


---

<p align="center">
  Desarrollado con ❤️ para el curso de <strong>Construcción de Software II</strong> — UPT 2026
</p>
