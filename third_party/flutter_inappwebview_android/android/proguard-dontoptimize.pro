# Added for IwrQk (see ../IWRQK_PATCH.md).
# proguard-android.txt used to disable optimization for this library's own release build.
# Keep that behavior after switching to proguard-android-optimize.txt for AGP 9.
# Not listed in consumerProguardFiles, so it does not affect the app's R8 configuration.
-dontoptimize
