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

package de.mightypirates.megazine.events {
	
	import flash.events.Event;
	
	/**
	 * Event fired by the scrollbar gui element when the position changes.
	 * 
	 * @author fnuecke
	 */
	public class ScrollBarEvent extends Event {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** Position of the scrollbar changed */
		public static const POSITION_CHANGED:String = "position_changed";
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** New percentual value of the position */
		private var _percent:Number;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new scrollbar event, with the new position of the scrollbar.
		 * @param type The type, only POSITION_CHANGED.
		 * @param percent New percentual value of the scrollbar.
		 */
		public function ScrollBarEvent(type:String, percent:Number = 0) { 
			super(type);
			_percent = percent;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The new percentual value of the scroll bar.
		 */
		public function get percent():Number {
			return _percent;
		}
		
	}
	
}
