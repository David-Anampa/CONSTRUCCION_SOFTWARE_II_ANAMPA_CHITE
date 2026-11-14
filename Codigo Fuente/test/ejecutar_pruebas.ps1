# /**
#  * Archivo/Clase : ejecutar_pruebas.ps1
#  * Proyecto      : SOSMASCOTA
#  * Autores       : David Anampa, Danilo Chite
#  * Fecha         : 13/11/2026
#  * Descripción   : Script PowerShell que ejecuta la suite completa de pruebas unitarias
#  *                 de Flutter y genera el reporte fechado en test\resultados_pruebas.txt.
#  * Se vincula con: - USA: CLI `flutter test --reporter=expanded` y archivos `test/*_test.dart`.
#  *                 - ES USADO POR: Desarrolladores / QA durante la verificación local.
#  * Funcionamiento: Construye un encabezado con fecha, cobertura por requerimiento y redirige
#  *                 la salida expandida de Flutter Test al archivo de resultados.
#  * Requerimiento : RF-01, RF-02, RF-04, RF-05, RF-12 (Automatización de pruebas)
#  */

# ejecutar_pruebas.ps1
# ============================================================
# SOSMascota v1.0 -- Script de Ejecucion de Pruebas Unitarias
# Construccion de Software I | UPT
# ============================================================
#
# USO:
#   cd <ruta_del_proyecto>
#   .\test\ejecutar_pruebas.ps1
#
# DESCRIPCION:
#   Ejecuta toda la suite de pruebas unitarias y guarda el
#   resultado con fecha y hora en test\resultados_pruebas.txt
# ============================================================

$fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$proyecto = "SOSMascota v1.0"
$curso = "Construccion de Software I - UPT"

$encabezado = "============================================================`r`n"
$encabezado += "INFORME DE PRUEBAS UNITARIAS`r`n"
$encabezado += "$proyecto`r`n"
$encabezado += "$curso`r`n"
$encabezado += "Fecha de ejecucion: $fecha`r`n"
$encabezado += "============================================================`r`n"
$encabezado += "`r`n"
$encabezado += "COBERTURA:`r`n"
$encabezado += "  RF-01 | Autenticar usuario    -> test\rf01_login_test.dart`r`n"
$encabezado += "  RF-02 | Registrar usuario     -> test\rf02_registro_test.dart`r`n"
$encabezado += "  RF-04 | Reporte de mascota    -> test\rf04_reporte_test.dart`r`n"
$encabezado += "  RF-05 | Avistamiento          -> test\rf05_avistamiento_test.dart`r`n"
$encabezado += "  RF-12 | Comentarios           -> test\rf12_comentarios_test.dart`r`n"
$encabezado += "  Misc  | Validaciones extra    -> test\validaciones_test.dart`r`n"
$encabezado += "  Misc  | Avistamiento original -> test\avistamiento_vm_test.dart`r`n"
$encabezado += "`r`n"
$encabezado += "RF-08 (Comunicar usuarios): STUB -- fuera de alcance v1.0.`r`n"
$encabezado += "  No hay pruebas para el stub ya que no contiene logica real.`r`n"
$encabezado += "`r`n"
$encabezado += "============================================================`r`n"
$encabezado += "RESULTADO DE flutter test --reporter=expanded:`r`n"
$encabezado += "============================================================`r`n"
$encabezado += "`r`n"

Write-Host "============================================================"
Write-Host "  SOSMascota -- Ejecutando pruebas unitarias..."
Write-Host "  Fecha: $fecha"
Write-Host "============================================================"
Write-Host ""

# Guardar encabezado
$encabezado | Out-File -FilePath "test\resultados_pruebas.txt" -Encoding UTF8

# Ejecutar y capturar salida de flutter test
$resultado = flutter test --reporter=expanded 2>&1
$resultado | Out-File -FilePath "test\resultados_pruebas.txt" -Encoding UTF8 -Append

# Mostrar resultado en consola
$resultado

# Pie del archivo
$pie = "`r`n============================================================`r`n"
$pie += "FIN DEL INFORME`r`n"
$pie += "Ejecutado: $fecha`r`n"
$pie += "Comando: flutter test --reporter=expanded`r`n"
$pie += "============================================================`r`n"
$pie | Out-File -FilePath "test\resultados_pruebas.txt" -Encoding UTF8 -Append

Write-Host ""
Write-Host "============================================================"
Write-Host "  Resultados guardados en: test\resultados_pruebas.txt"
Write-Host "============================================================"
