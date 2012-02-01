/*
MegaZine 3 - A Flash application for easy creation of book-like webpages.
Copyright (C) 2007-2008 Florian Nuecke

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.
*/

package de.mightypirates.megazine {
	
	import de.mightypirates.utils.Vector2D;
	
	/**
	 * This class is merely used to describe page movement paths. It can be seen as a
	 * mathematical function, mapping linear values to the actual position. Note that
	 * the progress of the function is handled automatically, though, increased via the
	 * step method.
	 * 
	 * @author fnuecke
	 */
	internal class DragPath {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** A linear movement */
		internal static const LINEAR:String     = "linear";
		
		/** Arched movement, bending to the left of the animation path */
		internal static const ARCH_LEFT:String  = "arch_left";
		
		/** Arched movement, bending to the right of the animation path */
		internal static const ARCH_RIGHT:String = "arch_right";
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The distance to travel per step */
		private var d:Number;
		
		/** The current time offset */
		private var t:Number = 0;
		
		/** The function we use to describe the path internally */
		private var f:Function;
		
		/** The current position */
		private var p:Vector2D;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new dragging path.
		 * @param startPosition The starting position
		 * @param endPosition The end position
		 * @param type The movement type (see constants)
		 * @param archFactor How steep the arch should be. 1 represents an arch that runs along
		 * a circle with its center between the start and end point. Higher is steeper, zero is
		 * a line.
		 * @param speed The speed, determines how fast to finish the animation. Determines how
		 * much distance is travelled every update.
		 */
		public function DragPath(startPosition:Vector2D, endPosition:Vector2D,
								 type:String = LINEAR, archFactor:Number = 1.0,
								 speed:Number = 20)
		{
			
			p = startPosition.clone();
			d = speed;
			
			switch (type) {
				
				case ARCH_LEFT:
					f = getArch(startPosition, endPosition, archFactor, true);
					break;
					
				case ARCH_RIGHT:
					f = getArch(startPosition, endPosition, archFactor, false);
					break;
					
				case LINEAR:
				default:
					f = getLine(startPosition, endPosition);
				
			}
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Gets the current position
		 * @return The current position
		 */
		public function getPosition():Vector2D {
			return p;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Generates a function describing an arched path between two points
		 * @param start The starting point
		 * @param end The ending point
		 * @param left Left or right side of the connecting line
		 * @return The function describing the path
		 */
		private function getArch(start:Vector2D, end:Vector2D,
								 factor:Number, left:Boolean = true):Function
		{
			
			// Remember starting point.
			var offset:Vector2D = start.clone();
			// Distance between start and end.
			var dist:Number = start.distance(end);
			// Normalized vector of the direction from start to finish.
			var direction:Vector2D = end.minus(start).normalize();
			// The normal on the direct line between start and end, depends on direction.
			var normal:Vector2D = left
									? direction.normalize().lhn()
									: direction.normalize().rhn();
			var sideways:Vector2D = new Vector2D();
			// The maximum height (reached when travelling half of the way)
			var maxHeight:Number = (dist * 0.5) * factor;
			
			return function(t:Number):Boolean {
					
					if (t < 0) t = 0;
					if (t > dist) t = dist;
					
					var height:Number = Math.sin(t / dist * Math.PI) * maxHeight;
					sideways.copy(normal);
					sideways.normalize(height);
					
					p.copy(direction);
					p.normalize(t);
					p.plusEquals(sideways);
					p.plusEquals(offset);
					
					return t == dist;
					
				};
		}
		
		/**
		 * Get a function describing a linear path from start to end
		 * @param start The starting point
		 * @param end The end point
		 * @return The function describing the path
		 */
		private function getLine(start:Vector2D, end:Vector2D):Function {
			
			var offset:Vector2D = start.clone();
			var dist:Number = start.distance(end);
			var direction:Vector2D = end.minus(start).normalize();
			
			return function(t:Number):Boolean {
					
					if (t < 0) t = 0;
					if (t > dist) t = dist;
					
					p.copy(offset.plus(direction.normalize(t)));
					
					return t == dist;
					
				};
			
		}
		
		/**
		 * Move the animation along by the given distance
		 * @param d The distance to move on
		 * @return True if the animation finished, false if not
		 */
		public function step():Boolean {
			t += d;
			return f(t);
		}
		
	}
	
}
