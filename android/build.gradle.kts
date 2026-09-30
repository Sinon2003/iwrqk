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
// Several plugins still declare an outdated compileSdk, which AGP 9 rejects when their AndroidX
// dependencies require a newer one (checkAarMetadata). Compile plugin modules against at least the
// app's compileSdk. This only changes compile-time APIs; minSdk and targetSdk are untouched.
// Registered before evaluationDependsOn(":app") so the hook exists before any plugin is configured.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.configure<com.android.build.api.variant.LibraryAndroidComponentsExtension> {
            finalizeDsl { android ->
                val appCompileSdk =
                    rootProject.project(":app")
                        .extensions.getByType<com.android.build.api.dsl.ApplicationExtension>()
                        .compileSdk ?: return@finalizeDsl
                if ((android.compileSdk ?: 0) < appCompileSdk) {
                    android.compileSdk = appCompileSdk
                }
            }
        }
    }
}
// Plugins migrated to AGP 9 built-in Kotlin no longer set a Kotlin jvmTarget, because built-in Kotlin
// derives it from compileOptions. With android.builtInKotlin=false, Flutter applies KGP instead, which
// defaults to the JDK version and then fails as inconsistent with the Java target. Align them here.
subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        val javaTarget =
            project.extensions.findByType<com.android.build.api.dsl.LibraryExtension>()
                ?.compileOptions?.targetCompatibility ?: return@configureEach
        compilerOptions.jvmTarget.set(
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(javaTarget.toString()),
        )
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
