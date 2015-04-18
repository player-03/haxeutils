/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2015 Joseph Cloutier
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

#if (openfl || flash)

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.display.Stage;
import flash.Lib;
import flash.ui.Keyboard;
import flash.Vector;

class Key {
	private static var keysPressed:Vector<Bool>;
	private static var mostRecentKey:Int;
	
	/**
	 * This is enough to handle any key listed in flash.ui.Keyboard.
	 */
	private static inline var ARRAY_LENGTH:Int = 223;
	
	private static var escapeKeyListener:KeyboardEvent -> Void;
	
	/**
	 * @param	escapeKeyListener Optional. If specified, KEY_UP events
	 * for the escape key will be passed to the function. On Android, the
	 * back button will be mapped to escape, and you can prevent the app
	 * from closing by calling stopImmediatePropagation() on the event.
	 */
	public static function init(?escapeKeyListener:KeyboardEvent -> Void):Void {
		keysPressed = Vector.ofArray([for(i in 0...ARRAY_LENGTH) false]);
		
		Key.escapeKeyListener = escapeKeyListener;
		
		var stage:Stage = Lib.current.stage;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage.addEventListener(Event.DEACTIVATE, clearAll);
	}
	
	private static function keyDownHandler(event:KeyboardEvent):Void {
		mostRecentKey = event.keyCode;
		if(mostRecentKey >= ARRAY_LENGTH) {
			return;
		}
		
		keysPressed[mostRecentKey] = true;
	}
	
	private static function keyUpHandler(event:KeyboardEvent):Void {
		clearKey(event.keyCode);
		
		if(escapeKeyListener != null && event.keyCode == Keyboard.ESCAPE) {
			escapeKeyListener(event);
		}
	}
	
	/**
	 * Clears all keys, whether or not they were released.
	 */
	public static function clearAll(?event:Event):Void {
		var index:Int;
		for(index in 0...ARRAY_LENGTH) {
			keysPressed[index] = false;
		}
	}
	
	/**
	 * Clears the given key, whether or not it was released. If the key
	 * was the most recently pressed, it may be recorded again.
	 */
	public static function clearKey(keyCode:Int):Void {
		if(keyCode >= ARRAY_LENGTH) {
			return;
		}
		
		keysPressed[keyCode] = false;
	}
	
	/**
	 * Clears the most recently pressed key. Warning: if this key is still
	 * being pressed, it may be recorded again.
	 */
	public static function clearMostRecent():Void {
		mostRecentKey = 0;
	}
	
	public static function isDown(keyCode:Int):Bool {
		if(keyCode >= ARRAY_LENGTH || keyCode < 0) {
			return false;
		}
		
		return keysPressed[keyCode];
	}
	
	/**
	 * @return The most recently pressed key.
	 */
	public static inline function getCode():Int {
		return mostRecentKey;
	}
	
	/**
	 * @return A string containing the name of the given key.
	 */
	public static function keyCodeToString(keyCode:Int):String {
		//Check if keyCode matches the ASCII value.
		if("0".code <= keyCode && keyCode <= "9".code
			|| "A".code <= keyCode && keyCode <= "Z".code) {
			return String.fromCharCode(keyCode);
		}
		
		switch(keyCode) {
			case 96:
				return "Numpad 0";
			case 97:
				return "Numpad 1";
			case 98:
				return "Numpad 2";
			case 99:
				return "Numpad 3";
			case 100:
				return "Numpad 4";
			case 101:
				return "Numpad 5";
			case 102:
				return "Numpad 6";
			case 103:
				return "Numpad 7";
			case 104:
				return "Numpad 8";
			case 105:
				return "Numpad 9";
			case 106:
				return "Numpad *";
			case 107:
				return "Numpad +";
			case 109:
				return "Numpad -";
			case 110:
				return "Numpad .";
			case 111:
				return "Numpad /";
			case 112:
				return "F1";
			case 113:
				return "F2";
			case 114:
				return "F3";
			case 115:
				return "F4";
			case 116:
				return "F5";
			case 117:
				return "F6";
			case 118:
				return "F7";
			case 119:
				return "F8";
			case 120:
				return "F9";
			case 122:
				return "F11";
			case 123:
				return "F12";
			case 124:
				return "F13";
			case 125:
				return "F14";
			case 126:
				return "F15";
			case 8:
				return "Backspace";
			case 9:
				return "Tab";
			case 13:
				return "Enter";
			case 16:
				return "Shift";
			case 17:
				return "Ctrl";
			case 20:
				return "Caps Lock";
			case 27:
				return "Esc";
			case 32:
				return "Space";
			case 33:
				return "Page Up";
			case 34:
				return "Page Down";
			case 35:
				return "End";
			case 36:
				return "Home";
			case 37:
				return "Left";
			case 38:
				return "Up";
			case 39:
				return "Right";
			case 40:
				return "Down";
			case 45:
				return "Insert";
			case 46:
				return "Delete";
			case 144:
				return "Num Lock";
			case 145:
				return "Scroll Lock";
			case 19:
				return "Break";
			case 186:
				return ";";
			case 187:
				return "+";
			case 189:
				return "-";
			case 191:
				return "/";
			case 192:
				return "~";
			case 219:
				return "[";
			case 220:
				return "\\";
			case 221:
				return "]";
			case 222:
				return "\"";
			case 188:
				return ",";
			case 190:
				return ".";
			default:
				return "Key #" + keyCode;
		}
	}
	
	/**
	 * This method has not yet been fully tested. Also, before using it,
	 * consider whether you can use flash.ui.Keyboard instead.
	 * @return The key code for the given character, or -1 if the
	 * character isn't recognized.
	 */
	public static function keyCodeFromChar(char:Int):Int {
		if("a".code <= char && char <= "z".code) {
			//Make it uppercase.
			char += "A".code - "a".code;
		}
		//A number of characters can be returned verbatim.
		if("0".code <= char && char <= "9".code
			|| "A".code <= char && char <= "Z".code
			|| "\t".code == char
			|| " ".code == char) {
			return char;
		}
		
		switch(char) {
			case "!".code:
				return "1".code;
			case "@".code:
				return "2".code;
			case "#".code:
				return "3".code;
			case "$".code:
				return "4".code;
			case "%".code:
				return "5".code;
			case "^".code:
				return "6".code;
			case "&".code:
				return "7".code;
			case "*".code:
				return "8".code;
			case "(".code:
				return "9".code;
			case ")".code:
				return "0".code;
			case "\n".code, "\r".code:
				return "\r".code;
			case "'".code, "\"".code:
				return 222;
			case "-".code, "_".code:
				return 189;
			case "=".code, "+".code:
				return 187;
			case ";".code, ":".code:
				return 186;
			case "/".code, "?".code:
				return 191;
			case "`".code, "~".code:
				return 192;
			case "[".code, "{".code:
				return 219;
			case "\\".code, "|".code:
				return 220;
			case "]".code, "}".code:
				return 221;
			case ",".code, "<".code:
				return 188;
			case ".".code, ">".code:
				return 190;
			default:
				return -1;
		}
	}
}

#end
