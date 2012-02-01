/*
Vector2D = represents a vector in 2D space with methods for manipulation.
Copyright (c) 2007-2008 Florian Nuecke

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package de.mightypirates.utils {
	
	/**
	 * Vector class for two dimensional vectors.
	 * 
	 * @version 1.0
	 * @author Florian Nuecke
	 */
	public class Vector2D {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** The origin vector (0, 0) */
		public static const ORIGIN:Vector2D = new Vector2D();
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** X length */
		public var x:Number;
		/** Y length */
		public var y:Number;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Constructor
		 * @param initX The initial x length of the vector
		 * @param initY The initial y length of the vector
		 */
		public function Vector2D(initX:Number = 0,
								 initY:Number = 0):void {
			x = initX;
			y = initY;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Gets the component-wise maximum of any number of vectors
		 * @param v First vector
		 * @param vs More vectors...
		 */
		public static function max(v:Vector2D, ... vs:Array):Vector2D {
			var ret:Vector2D = v.clone();
			
			if (vs) {
				for (var i:int = 0; i<vs.length; i++) {
					// Type check...
					if (vs[i] is Vector2D) {
						// Get the bigger ones
						ret.x = Math.max(ret.x, vs[i].x);
						ret.y = Math.max(ret.y, vs[i].y);
					}
				}
			}
			
			return ret;
			
		}
		
		/**
		 * Gets the component-wise minimum of any number of vectors
		 * @param v First vector
		 * @param vs More vectors...
		 */
		public static function min(v:Vector2D, ... vs:Array):Vector2D {
			var ret:Vector2D = v.clone();
			
			if (vs) {
				for (var i:int = 0; i<vs.length; i++) {
					// Type check...
					if (vs[i] is Vector2D) {
						// Get the smaller ones
						ret.x = Math.min(ret.x, vs[i].x);
						ret.y = Math.min(ret.y, vs[i].y);
					}
				}
			}
			
			return ret;
			
		}
		
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Get the magnitude of the vector (calls Vector2D.distance)
		 * @return The length/magnitude of this vector
		 */
		public function get magnitude():Number {
			return distance();
		}
		/**
		 * Set the magnitude of the vector (using the normalize function)
		 * @param f The new length of the vector
		 */
		public function set magnitude(f:Number):void {
			normalize(f);
		}
		
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Set the lengths, if no argument/s is/are given sets to axis/origin
		 * @param newX The new x length
		 * @param newY The new y length
		 * @return This vector after setting new values
		 */
		public function setTo(newX:Number = 0,
							  newY:Number = 0):Vector2D {
			x = newX;
			y = newY;
			
			return this;
		}
		
		/**
		 * Copy the x and y lengths another vector
		 * @param v The vector that should be copied
		 * @return This vector after setting new values
		 */
		public function copy(v:Vector2D = null):Vector2D {
			v ||= ORIGIN;
			x = v.x;
			y = v.y;
			
			return this;
		}
		
		/**
		 * Add another vector to this one
		 * @param v The vector to add
		 * @return This vector after addition
		 */
		public function plusEquals(v:Vector2D = null):Vector2D {
			v ||= ORIGIN;
			x+= v.x;
			y+= v.y;
			
			return this;
		}
		
		/**
		 * Subtract another vector from this one
		 * @param v The vector to subtract
		 * @return This vector after subtraction
		 */
		public function minusEquals(v:Vector2D = null):Vector2D {
			v ||= ORIGIN;
			x-= v.x;
			y-= v.y;
			
			return this;
		}
		
		/**
		 * Skalar multiplikation
		 * @param f The skalar number to multiply the vector with
		 * @return This vector after multiplication
		 */
		public function multEquals(f:Number = 1):Vector2D {
			x*= f;
			y*= f;
			
			return this;
		}
		
		/**
		 * Skalar division
		 * @param f The skalar number to divide the vector by
		 * @return This vector after division
		 */
		public function divEquals(f:Number = 1):Vector2D {
			x/= f;
			y/= f;
			
			return this;
		}
		
		/**
		 * Normalize the vector, or bring it to the given length if argument is passed
		 * @param f The new length of the vector
		 * @return This vector after normalization
		 */
		public function normalize(f:Number = 1):Vector2D {
			var mag:Number = magnitude;
			// If the magnitude is 0, raise a warning
			if (mag == 0) {
				throw new ArgumentError("Trying to normalize a vector with zero length.");
			} else {
				divEquals(mag / f);
			}
			
			return this;
		}
		
		/**
		 * Rotate the vector, optionally around a user-specified origin, defined via another vector
		 * @param r The angle by which the vector should be rotated in radiants
		 * @param v The vector defining the origin
		 * @return This vector after rotation
		 */
		public function rotate(r:Number,
							   v:Vector2D = null):Vector2D {
			v ||= ORIGIN;
			r+= Math.atan2(y - v.y, x - v.x);
			var dist:Number = distance(v);
			x = v.x + Math.cos(r) * dist;
			y = v.y + Math.sin(r) * dist;
			
			return this;
		}
		
		/**
		 * Creates a clone of this vector
		 * @return A duplicate of this vector
		 */
		public function clone():Vector2D {
			return new Vector2D(x, y);
		}
		 
		/**
		 * Add another vector to this one, return a new vector without changing this one
		 * @param v The vector to add
		 * @return A new vector that represents this vector after the addition
		 */
		public function plus(v:Vector2D = null):Vector2D {
			v ||= ORIGIN;
			return new Vector2D(x + v.x, y + v.y); 
		}
		
		/**
		 * Subtract another vector from this one, return a new vector without changing this one
		 * @param v The vector to subtract
		 * @return A new vector that represents this vector after the subtraction
		 */
		public function minus(v:Vector2D = null):Vector2D {
			v ||= ORIGIN;
			
			return new Vector2D(x - v.x, y - v.y);
		}
		
		/**
		 * Skalar multiplikation, return a new vector without changing this one
		 * @param f The skalar number to multiply the vector with
		 * @return A new vector that represents this vector after being multiplied
		 */
		public function mult(f:Number = 1):Vector2D {
			return new Vector2D(x * f, y * f);
		}
		
		/**
		 * Skalar division, return a new vector without changing this one
		 * @param f The skalar number to divide the vector by
		 * @return A new vector that represents this vector after being divided
		 */
		public function div(f:Number = 1):Vector2D {
			return new Vector2D(x / f, y / f);
		}
		
		/**
		 * Project this vector onto another one
		 * @param v The vector to project this one onto
		 * @return The projection
		 */
		public function project(v:Vector2D):Vector2D {
			var dp:Number = (x * v.x + y * v.y) / (v.x * v.x + v.y * v.y);
			
			return new Vector2D(dp * v.x, dp * v.y);
		}
		
		/**
		 * Get the right hand normal for the vector
		 * @return The right hand normal
		 */
		public function rhn():Vector2D {
			return new Vector2D(-y, x);
		}
		
		/**
		 * Get the left hand normal for the vector
		 * @return The left hand normal
		 */
		public function lhn():Vector2D {
			return new Vector2D(y, -x);
		}
		
		/**
		 * Interpolate two vectors, per default the middle.
		 * @param v The other vector
		 * @param f The percentual position between the two (0 = this, 1 = v)
		 * @return This vector after it was interpolated
		 */
		public function interpolate(v:Vector2D = null,
									f:Number = 0.5):Vector2D {
			v ||= ORIGIN;
			x+= (v.x - x) * f;
			y+= (v.y - y) * f;

			return this;
		}
		 
		/**
		 * The dot product of this and another vector
		 * @param v The other vector
		 * @return The dot product
		 */
		public function dot(v:Vector2D = null):Number {
			v ||= ORIGIN;
			
			return x * v.x + y * v.y;
		}
		
		/**
		 * The cross product of this and another vector
		 * @param v The other vector
		 * @return The cross product
		 */
		public function cross(v:Vector2D = null):Number {
			v ||= ORIGIN;
			
			return x * v.y - y * v.x;
		}
		
		/**
		 * Get the distance between the points two vectors describe.
		 * @param v The other vector
		 * @return The distance
		 */
		public function distance(v:Vector2D = null):Number {
			v ||= ORIGIN;
			var dX:Number = x - v.x;
			var dY:Number = y - v.y;
			
			return Math.sqrt(dX * dX + dY * dY);
		}
		
		/**
		 * Returns a string representation of this vector
		 * @return x:y
		 */
		public function toString():String {
			return "Vector2D[x="+x+", y="+y+"]";
		}
		
	}
	
}
