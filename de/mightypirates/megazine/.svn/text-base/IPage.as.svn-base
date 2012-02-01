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
	
	import flash.display.*;
	import flash.events.IEventDispatcher;
	
	/**
	 * Interface for the Page class, to be used in elements. Especially for external objects,
	 * to reduce file size (by only importing the interface and not the actual class with all
	 * the code). The actual class is not needed by external elements because they do not need
	 * to instantiate new Page objects.
	 * 
	 * @author fnuecke
	 */
	public interface IPage extends IEventDispatcher {
		
		/**
		 * Tells whether the page is a stiff or a normal page.
		 */
		function get isStiff():Boolean;
		
		/**
		 * Get the even page part
		 * @return The even page display object
		 */
		function get pageEven():DisplayObjectContainer;
		
		/**
		 * Get the odd page part
		 * @return The odd page display object
		 */
		function get pageOdd():DisplayObjectContainer;
		
		/**
		 * Gets the page's state
		 * @return Current page state
		 */
		function get state():String;
		
		/**
		 * Get this page's background color
		 * @param even For the even page, or for the odd one
		 * @return This page's background color
		 */
		function getBackgroundColor(even:Boolean):uint;
		
		/**
		 * Get the page's number. Not that this returns the logical page number, i.e. the
		 * count starts at 1. This is because this method is mainly used for display in
		 * the gui and so on.
		 * @return The page number
		 */
		function getNumber(even:Boolean):uint;
		
		/**
		 * Get the BitMap object that is used for rendering the thumbnail.
		 * This BitMap is updated automatically.
		 * @return The BitMap with the thumbnail.
		 */
		function getPageThumbnail(even:Boolean):Bitmap;
		
		/**
		 * Get whether the even or odd page is visible or not.
		 * @param even Even or odd page.
		 * @return Visible or nor.
		 */
		function getPageVisible(even:Boolean):Boolean;
		
	}
	
}
