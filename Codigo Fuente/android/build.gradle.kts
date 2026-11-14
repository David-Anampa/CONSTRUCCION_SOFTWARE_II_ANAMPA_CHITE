// Archivo       : android/build.gradle.kts
// Proyecto      : SOSMASCOTA
// Autores       : David Anampa, Danilo Chite
// Fecha         : 13/11/2026
// Descripción   : Configuración Gradle de nivel raíz para la compilación Android del proyecto.
// Se vincula con: android/settings.gradle.kts, android/app/build.gradle.kts y plugins AGP / Google Services.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.9.1")
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
