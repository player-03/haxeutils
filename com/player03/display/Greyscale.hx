/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2017 Joseph Cloutier
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

package com.player03.display;

import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;

class Greyscale {
	/**
	 * Color multipliers recommended by the ITU to make the result appear to the
	 * human eye to have the correct brightness. See page 3 of the article at
	 * http://www.itu.int/rec/R-REC-BT.601-7-201103-I/en for more information.
	 */
	private static inline var RED:Float = 0.299;
	private static inline var GREEN:Float = 0.587;
	private static inline var BLUE:Float = 0.114;
	
	/**
	 * A ColorMatrixFilter uses a 4x5 matrix to transform the colors, but takes it
	 * as a 1D array with the appropriate number of indices.
	 */
	private static var greyscaleFilters:Array<BitmapFilter> =
		[(cast new ColorMatrixFilter([
			RED, GREEN, BLUE, 0, 0,
			RED, GREEN, BLUE, 0, 0,
			RED, GREEN, BLUE, 0, 0,
			0,   0,     0,    1, 0])
		:BitmapFilter)];
	
	public static inline function applyGreyscale(target:DisplayObject):Void {
		target.filters = greyscaleFilters;
	}
	
	/**
	 * @param amount - A number between 0 and 1. At 0, the target will have full saturation,
	 * while at 1, the target will be fully greyscale.
	 */
	public static function applyPartialGreyscale(target:DisplayObject, ?amount:Float = 0.5):Void {
		target.filters = [(cast new ColorMatrixFilter([
				1 + (RED - 1) * amount, GREEN * amount,           BLUE * amount,           0, 0,
				RED * amount,           1 + (GREEN - 1) * amount, BLUE * amount,           0, 0,
				RED * amount,           GREEN * amount,           1 + (BLUE - 1) * amount, 0, 0,
				0,                      0,                        0,                       1, 0])
			:BitmapFilter)];
	}
	
	public static inline function removeGreyscale(target:DisplayObject):Void {
		target.filters = null;
	}
	
	public static function colorToGreyscale(color:Int):Int {
		return Std.int(((color >> 16) & 0xFF) * RED)
			+ Std.int(((color >> 8) & 0xFF) * GREEN)
			+ Std.int((color & 0xFF) * BLUE);
	}
}
