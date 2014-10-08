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

[NDLLClassBuilder.hx](https://github.com/player-03/haxeutils/blob/master/com/player03/haxeutils/NDLLClassBuilder.hx)
===================

Like JNIClassBuilder, except it generates the code necessary to call C++ functions that have been compiled into an NDLL.

Let's say you compile the [sample extension](https://github.com/openfl/lime/tree/master/templates/extension) into `testext.ndll` and add it to your project. This static function would allow you to call SampleMethod():

    #if !macro @:build(com.player03.haxeutils.NDLLClassBuilder.build()) #end
    class TestExt {
        @ndll("testext", "testext") public static function SampleMethod(inputValue:Int):Int;
    }

The two arguments passed to the `@ndll` metadata tell the class builder which NDLL to look in, and which namespace the function is found in. The two are often the same, but advanced users may want to use multiple different namespaces.

If you don't want to type them for every single function, you can also specify defaults:

    #if !macro @:build(com.player03.haxeutils.NDLLClassBuilder.build("testext", "testext")) #end
    class TestExt {
        @ndll public static function SampleMethod(inputValue:Int):Int;
    }

If you're responsible for building the NDLL, you may want to use [ExtensionBoilerplate](https://github.com/player-03/ExtensionBoilerplate) as well.
