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

package com.player03.geom;

#if flixel
typedef Point = flixel.util.FlxPoint;
#elseif openfl
typedef Point = openfl.geom.Point;
#elseif lime
typedef Point = lime.math.Vector2;
#elseif flambe
typedef Point = flambe.math.Point;
#elseif luxe
typedef Point = luxe.Vector;
#elseif flash
typedef Point = flash.geom.Point;
#else
class Point {
	public var x:Float;
	public var y:Float;
	
	public function new(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}
}
#end
