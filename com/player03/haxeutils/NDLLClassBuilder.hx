/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2014 Joseph Cloutier
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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

class NDLLClassBuilder {
	public static macro function build(?defaultNDLL:String, ?defaultFunctionPrefix:String):Array<Field> {
		if(defaultFunctionPrefix == null) {
			defaultFunctionPrefix = "";
		} else if(defaultFunctionPrefix.charCodeAt(defaultFunctionPrefix.length - 1) != "_".code) {
			defaultFunctionPrefix += "_";
		}
		
		var builder:ClassBuilder = new ClassBuilder();
		var fields:Array<Field> = Context.getBuildFields();
		
		var ndllFunctions:Array<Member> = new Array<Member>();
		var ndllMetaTags:Array<Array<String>> = new Array<Array<String>>();
		for(field in Context.getBuildFields()) {
			var member:Member = field;
			if(member.isStatic && OutcomeTools.isSuccess(member.getFunction())) {
				var extractMetaOutcome = member.extractMeta("ndll");
				if(OutcomeTools.isSuccess(extractMetaOutcome)) {
					ndllFunctions.push(member);
					if(Reflect.hasField(OutcomeTools.sure(extractMetaOutcome), "params")) {
						var tags:Array<String> = new Array<String>();
						ndllMetaTags.push(tags);
						for(tagExpr in OutcomeTools.sure(extractMetaOutcome).params) {
							tags.push(OutcomeTools.sure(Exprs.getString(tagExpr)));
						}
					} else {
						ndllMetaTags.push(null);
					}
				}
			}
		}
		
		var isLowercase:Int -> Bool = function(char:Int):Bool {
			return char >= "a".code && char <= "z".code;
		};
		var isUppercase:Int -> Bool = function(char:Int):Bool {
			return char >= "A".code && char <= "Z".code;
		};
		var isNumeric:Int -> Bool = function(char:Int):Bool {
			return char >= "0".code && char <= "9".code;
		};
		
		var returnsVoid:Function -> Bool = function(func:Function):Bool {
			if(func.ret == null) {
				return true;
			} else {
				switch(func.ret) {
					case TPath(p):
						return p.name == "Void";
					default:
						throw "Unrecognized function return type: " + func.ret;
						return true;
				}
			}
		};
		
		for(i in 0...ndllFunctions.length) {
			var member:Member = ndllFunctions[i];
			var tags:Array<String> = ndllMetaTags[i];
			var asFunction:Function = OutcomeTools.sure(member.getFunction());
			builder.removeMember(OutcomeTools.sure(builder.memberByName(member.name)));
			
			var ndllFile:String;
			if(tags != null && tags.length >= 1) {
				ndllFile = tags[0];
			} else {
				ndllFile = defaultNDLL;
			}
			
			var ndllName:String;
			if(tags != null && tags.length >= 3) {
				ndllName = tags[2];
			} else {
				//To ensure correct word boundaries, place underscores before
				//any uppercase letter that is EITHER preceeded or followed
				//by a lowercase letter. For instance, "sampleNDLLFunction"
				//becomes "sample_NDLL_Function". (Before being converted to
				//lowercase.) Also place them before and after numbers.
				ndllName = member.name;
				var underscoresPlaced:Int = 0;
				var i:Int = ndllName.length;
				var current:Int;
				var before:Int;
				var after:Int = -1;
				var addUnderscore:Bool;
				while(i --> 1) { //This is the "converges to" operator. :P
					current = StringTools.fastCodeAt(ndllName, i);
					before = StringTools.fastCodeAt(ndllName, i - 1);
					
					addUnderscore = false;
					if(isUppercase(current)) {
						//"aA" becomes "a_A"
						addUnderscore = isLowercase(before)
							//"AAa" becomes "A_Aa"
							|| isUppercase(before) && isLowercase(after);
					} else if(isNumeric(current)) {
						//"a1" becomes "a_1"
						addUnderscore = isLowercase(before) || isUppercase(before);
					} else if(isLowercase(current)) {
						//"1a" becomes "1_a"
						addUnderscore = isNumeric(before);
					}
					
					if(addUnderscore) {
						ndllName = ndllName.substr(0, i) + "_" + ndllName.substr(i);
					}
					
					after = current;
				}
			}
			
			ndllName = ndllName.toLowerCase();
			
			//Add the function prefix.
			if(tags != null && tags.length >= 2) {
				ndllName = tags[1] + ndllName;
			} else {
				ndllName = defaultFunctionPrefix + ndllName;
			}
			
			//In the function body, initialize the NDLL function if necessary.
			var memberBody:Expr = macro {
				if($i{ndllName} == null) {
					$i{ndllName} = cpp.Lib.load($v{ndllFile},
								$v{ndllName}, $v{asFunction.args.length});
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
			
			//Add instructions to call the NDLL function, returning its
			//result unless it returns void. Assembling the function call
			//makes it infeasible to include this in the macro{} block above.
			var ndllCall:Expr = Exprs.call(macro {$i{ndllName}},
					[for(arg in asFunction.args) macro {$i{arg.name}}]);
			if(returnsVoid(asFunction)) {
				memberBodyArray.push(ndllCall);
			} else {
				memberBodyArray.push(Exprs.at(EReturn(ndllCall)));
			}
			
			var newMember:Member = Member.method(member.name,
				Functions.func(memberBody, asFunction.args, asFunction.ret, asFunction.params, false));
			newMember.isStatic = member.isStatic;
			newMember.isPublic = member.isPublic;
			builder.addMember(newMember);
			
			//Create a variable to store the NDLL function.
			newMember = Member.prop(ndllName,
							Types.toComplex(TDynamic(null)),
							Context.currentPos(), true, true);
			newMember.isPublic = false;
			newMember.isStatic = true;
			builder.addMember(newMember);
		}
		
		return builder.export();
	}
}
