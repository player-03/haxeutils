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

import flash.Lib;
import flash.Vector;
import flash.events.Event;

class FrameDelay {
	private static var enterFrameCount:Int = 0;
	private static var callbackGroups:Vector<CallbackGroup>;
	
	private static inline function init():Void {
		callbackGroups = new Vector<CallbackGroup>();
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, -1);
	}
	
	/**
	 * Calls the given callback after the given number of ENTER_FRAME
	 * events are dispatched, plus one. (Because otherwise it's liable
	 * to fire almost immediately.)
	 */
	public static function delay(callback:Void -> Void, frameCount:Int = 1):Void {
		if(frameCount < 0) {
			return;
		}
		
		if(callbackGroups == null) {
			init();
		}
		
		var until:Int = enterFrameCount + 1 + frameCount;
		
		for(group in callbackGroups) {
			if(group.until == until) {
				group.callbacks.push(callback);
				return;
			}
		}
		
		var group:CallbackGroup = new CallbackGroup(until);
		group.callbacks.push(callback);
		callbackGroups.push(group);
		
		if(callbackGroups.length > 1) {
			callbackGroups.sort(sort);
		}
	}
	
	private static function onEnterFrame(e:Event):Void {
		enterFrameCount++;
		
		while(callbackGroups.length > 0 && callbackGroups[0].until <= enterFrameCount) {
			for(callback in callbackGroups.shift().callbacks) {
				callback();
			}
		}
	}
	
	private static function sort(a:CallbackGroup, b:CallbackGroup):Int {
		return a.until - b.until;
	}
}

class CallbackGroup {
	public var callbacks:Vector<Void -> Void>;
	public var until:Int;
	
	public function new(until:Int) {
		callbacks = new Vector<Void -> Void>();
		this.until = until;
	}
}

#end
