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
	
	import flash.display.*;
	import flash.text.TextField;
	
	/**
	 * For page number display left and right to page navigation.
	 * 
	 * @author fnuecke
	 */
	public class PageNumber extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Number of total pages. */
		private var totalPages:uint = 0;
		
		/** The label for displaying the page number */
		private var numberDisplay:TextField;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Initialize a new page number display.
		 * @param pages Number of total pages.
		 * @param lib Graphics library to obtain graphics from.
		 * @throws an error if it fails to get the graphics from the library.
		 */
		public function PageNumber(pages:uint, lib:Library) {
			totalPages = pages;
			var gui:DisplayObject = lib.getInstanceOf(LibraryConstants.PAGE_NUMBER);
			addChild(gui);
			numberDisplay = gui["label"];
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Sets the number for this page number display.
		 * @param num The number to display.
		 */
		internal function setNumber(num:uint):void {
			if (num < 1 || num > totalPages) {
				numberDisplay.text = "-";
			} else {
				numberDisplay.text = String(num);
			}
		}
		
	}
	
}