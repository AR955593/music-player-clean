allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Ensure all subprojects (including Android plugins) compile with Java 17 / Kotlin JVM 17
subprojects {
    // Configure Java compile tasks
    tasks.withType(JavaCompile::class.java).configureEach {
        // Always set source/target compatibility
        sourceCompatibility = "17"
        targetCompatibility = "17"

        // For Android projects, do NOT set the `--release` option because
        // the Android Gradle plugin needs to set up the bootclasspath
        // itself. For non-Android projects, use `--release` where available
        // to ensure consistent bytecode.
        val isAndroid = project.plugins.hasPlugin("com.android.library") ||
                project.plugins.hasPlugin("com.android.application")
        if (!isAndroid) {
            try {
                options.release.set(17)
            } catch (_: Exception) {
            }
        }
    }

    // Configure Kotlin compile tasks
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        val isAndroid = project.plugins.hasPlugin("com.android.library") ||
            project.plugins.hasPlugin("com.android.application")
        val isAppModule = project.name == "app" || project.path == ":app"
        kotlinOptions.jvmTarget = if (isAndroid && !isAppModule) "1.8" else "17"
    }
}
    // Ensure Android projects' compileOptions are set to Java 17 as AGP may
    // override JavaCompile settings later in configuration.
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    plugins.withId("com.android.application") {
        extensions.configure<com.android.build.gradle.AppExtension>("android") {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
