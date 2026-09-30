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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
