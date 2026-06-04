# ProGuard rules for Day Script app

# Isar
-keep class dev.isar.** { *; }
-keep class **.isar.** { *; }
-dontwarn dev.isar.**

# Flutter Quill
-keep class com.quill.** { *; }
-dontwarn com.quill.**

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Local Auth
-keep class io.flutter.plugins.localauth.** { *; }

# Google Fonts
-keep class com.google.android.gms.fonts.** { *; }

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.** { *; }
