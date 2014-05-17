haxeutils
=========

A set of utility classes that don't really fit anywhere else.

[JNIClassBuilder.hx](https://github.com/player-03/haxeutils/blob/master/com/player03/haxeutils/JNIClassBuilder.hx)
==================

A class to streamline the process of using JNI functions on Android.

**Required libraries:**

- openfl
- openfl-native
- tink_macro

**The problem:**

JNI functions are a hassle.

    class SampleClassName {
        private static var jniSampleFunction1:Int -> String -> Bool;
        public static function sampleFunction1(var1:Int, var2:String):Bool {
            if(jniSampleFunction1 == null) {
                jniSampleFunction1 = openfl.utils.JNI.createStaticMethod(
                            "com/example/package/name/SampleClassName",
                            "sampleFunction1",
                            "(ILjava/lang/String;)Z");
            }
            
            return jniSampleFunction1(var1, var2);
        }
        
        private static var jniSampleFunction2:Void -> Float;
        public static function sampleFunction2():Float {
            if(jniSampleFunction2 == null) {
                jniSampleFunction2 = openfl.utils.JNI.createStaticMethod(
                            "com/example/package/name/SampleClassName",
                            "sampleFunction2",
                            "()F");
            }
            
            return jniSampleFunction2();
        }
    }

Now imagine changing the return type on one of those functions. In addition to
changing the Java code, you'll have to replicate the change in three different
places in the above code.

**The solution:**

    #if !macro @:build(com.player03.haxeutils.JNIClassBuilder.build()) #end
    class SampleClassName {
        @jni public static function sampleFunction1(var1:Int, var2:String):Bool;
        @jni public static function sampleFunction2():Float;
    }

Much easier!

**Notes:**

The package, class name, and function name must exactly match the Java code.

Only static functions are supported. Functions may be private or public, but the
Java version must be public either way. Make sure the function name and signature
matches that of the Java version.

Bool maps to boolean, Int maps to int, Float maps to float (not double, sorry),
String maps to String (OpenFL handles the conversion, so don't worry about Java
strings being different from C strings), and Void maps to TAKE A WILD GUESS.

Compile with `-DjniClassBuilderDebugJNI` (or `<haxedef name="jniClassBuilderDebugJNI">`)
to print a message just before creating each function. This will let you know
which funcctions aren't working, even if CheckJNI doesn't.

iOS version coming eventually???
