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

package de.mightypirates.megazine.gui {
	
	import flash.display.DisplayObject;
	
	/**
	 * Interface for the swf loaded containing the actual library items.
	 * 
	 * @author fnuecke
	 */
	public interface ILibrarySWF {
		
		// ----------------------------------------------------------------------------------- //
		// Getter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Provides new instances of elements in the library.
		 * @param type The id of the element to get. Use constants from
		 * the LibraryConstants class.
		 */
		function getInstanceOf(type:String):DisplayObject;
		
		/** Version number of the library */
		function getVersion():Number;
		
	}
	
}