# Proguard Rules untuk iOS Gallery App

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# photo_manager
-keep class com.fluttercandies.photo_manager.** { *; }

# Hive
-keep class * extends com.google.flatbuffers.Table { *; }
-keepattributes Signature

# Keep Kotlin data classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Glide (used by photo_manager internally)
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep class * extends com.bumptech.glide.module.AppGlideModule {
    <init>(...);
}

# Prevent stripping of serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
