/// Module que gestiona la disponibilidad de Firebase.
/// 
/// En web, Firebase puede no estar disponible si faltan credenciales.
/// En móvil, generalmente siempre está disponible.

bool firebaseAvailable = false;

/// Inicializa el estado de disponibilidad de Firebase
void initializeFirebaseAvailability(bool isAvailable) {
  firebaseAvailable = isAvailable;
}

/// Obtiene el estado actual de disponibilidad de Firebase
bool getFirebaseAvailability() {
  return firebaseAvailable;
}
