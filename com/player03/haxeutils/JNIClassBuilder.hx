package com.player03.haxeutils;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.core.Outcome;
import tink.macro.ClassBuilder;
import tink.macro.Exprs;
import tink.macro.Functions;
import tink.macro.Member;
import tink.macro.Types;

/**
 * To enable, add the following before the class definition:
 * #if (android && !macro) @:build(com.player03.haxeutils.JNIClassBuilder.build()) #end
 * @author Joseph Cloutier
 */
class JNIClassBuilder {
	public static macro function build():Array<Field> {
		var classPath:String = Context.getLocalClass().toString().split(".").join("/");
		
		var builder:ClassBuilder = new ClassBuilder();
		var fields:Array<Field> = Context.getBuildFields();
		
		var jniFunctions:Array<Field> = Lambda.array(Lambda.filter(Context.getBuildFields(),
			function(field:Field):Bool {
				var member:Member = field;
				return member.isStatic
					&& OutcomeTools.isSuccess(member.getFunction())
					&& OutcomeTools.isSuccess(member.extractMeta("jni"));
			}));
		
		var newMember:Member = Member.prop("inited",
				Types.toComplex(Context.getType("Bool")),
				Context.currentPos(), true, true);
		newMember.isPublic = false;
		newMember.isStatic = true;
		builder.addMember(newMember);
		
		var convertToJNIType:Null<ComplexType> -> String
			= function(type:Null<ComplexType>):String {
			if(type == null) {
				return "V";
			} else {
				switch(type) {
					case TPath(p):
						switch(p.name) {
							case "Bool":
								return "Z";
							case "Int":
								return "I";
							case "Float":
								return "F";
							case "String":
								return "Ljava/lang/String;";
							default:
								return "V";
						}
					default:
						return "V";
				}
			}
		};
		
		//Replace the @jni functions with functions that make the
		//correct JNI call.
		for(field in jniFunctions) {
			var member:Member = field;
			var asFunction:Function = OutcomeTools.sure(member.getFunction());
			builder.removeMember(OutcomeTools.sure(builder.memberByName(member.name)));
			
			var jniName:String = "jni" + member.name.substr(0, 1).toUpperCase()
						+ member.name.substr(1);
			
			//While we're at it, convert the method signature to a JNI
			//signature. See Wikipedia's JNI article for more information.
			var jniSignature:String = "(";
			for(arg in asFunction.args) {
				jniSignature += convertToJNIType(arg.type);
			}
			jniSignature += ")" + convertToJNIType(asFunction.ret);
			
			//Initialize the JNI function if necessary, and print debug
			//info if appropriate.
			var memberBody:Expr = macro {
				if($i{jniName} == null) {
					#if jniClassBuilderDebugJNI
						haxe.Log.trace("Creating JNI function:");
						haxe.Log.trace($v{classPath}
									+ "." + $v{member.name}
									+ $v{jniSignature});
					#end
					
					$i{jniName} = openfl.utils.JNI.createStaticMethod(
									$v{classPath},
									$v{member.name},
									$v{jniSignature});
				}
			};
			
			//Get the array of expressions making up the function, so that
			//a final instruction can be appended.
			var memberBodyArray:Array<Expr> = null;
			switch(memberBody.expr) {
				case EBlock(a):
					memberBodyArray = a;
				default:
					//Shouldn't happen.
			}
			
			//Add instructions to call the JNI function, returning its
			//result unless it returns void. Assembling the function call
			//makes it infeasible to include this in the macro{} block above.
			var jniCall:Expr = Exprs.call(macro {$i{jniName}},
					[for(arg in asFunction.args) macro {$i{arg.name}}]);
			if(convertToJNIType(asFunction.ret) == "V") {
				memberBodyArray.push(jniCall);
			} else {
				memberBodyArray.push(Exprs.at(EReturn(jniCall)));
			}
			
			newMember = Member.method(member.name,
				Functions.func(memberBody, asFunction.args, asFunction.ret, asFunction.params, false));
			newMember.isStatic = member.isStatic;
			newMember.isPublic = member.isPublic;
			builder.addMember(newMember);
			
			//Create a variable to store the JNI function. This means
			//converting the method signature to Haxe's X -> Y -> Z format.
			var type:Type = TFun(
				[for(arg in asFunction.args) {name:arg.name, opt:arg.opt,
					t:OutcomeTools.orUse(Types.toType(arg.type), TDynamic(null))}],
				OutcomeTools.orUse(Types.toType(asFunction.ret), TDynamic(null)));
			newMember = Member.prop(jniName,
							Types.toComplex(type),
							Context.currentPos(), true, true);
			newMember.isPublic = false;
			newMember.isStatic = true;
			builder.addMember(newMember);
		}
		
		return builder.export();
	}
}
