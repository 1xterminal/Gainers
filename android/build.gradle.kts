// android/build.gradle.kts
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val project = this
    project.buildDir = File(newBuildDir.asFile, project.name)
    
    project.afterEvaluate {
        // Cari plugin android di setiap modul
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                // PAKSA SEMUA PLUGIN PAKAI SDK 36
                val compileMethod = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                compileMethod.invoke(android, 36)
            } catch (e: Exception) {
               // Ignore error, lanjut terus
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}