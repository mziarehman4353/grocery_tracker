allprojects {
    repositories {
        google()  // Ensure this is present
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

// Add the following classpath for Firebase
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Firebase services classpath
        classpath("com.google.gms:google-services:4.4.0")  // or the latest version
    }
}
