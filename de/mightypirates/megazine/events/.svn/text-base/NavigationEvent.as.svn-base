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
	 * Event fired by the navigation when a button is pressed.
	 * 
	 * @author fnuecke
	 */
	public class NavigationEvent extends Event {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** Go to fullscreen mode */
		public static const BUTTON_CLICK:String = "button_click";
		
		
		/** Go to fullscreen mode */
		public static const FULLSCREEN:String  = "fullscreen";
		
		/** Go to specified page */
		public static const GOTO_PAGE:String   = "goto_page";
		
		/** Help button was pressed */
		public static const HELP:String        = "help";
		
		/** Mute all sounds */
		public static const MUTE:String        = "mute";
		
		/** Go to first page in book */
		public static const PAGE_FIRST:String  = "page_first";
		
		/** Go to last page in book */
		public static const PAGE_LAST:String   = "page_last";
		
		/** Pause slideshow */
		public static const PAUSE:String       = "pause";
		
		/** Start slideshow */
		public static const PLAY:String        = "play";
		
		/** Return to normal mode (from fullscreen mode) */
		public static const RESTORE:String     = "restore";
		
		/** Open settings dialog */
		public static const SETTINGS:String    = "settings";
		
		/** Unmute sounds */
		public static const UNMUTE:String      = "unmute";
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** For go to page events, the page number */
		private var _page:uint;
		
		/** The subtype, more specifically the id of the button that was pressed. */
		private var _subtype:String;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new navigation event.
		 * @param type The id of the button that was pressed, see constants.
		 * @param page If it's a goto page event, which page to go to.
		 */
		public function NavigationEvent(type:String, page:uint = 0) {
			super(BUTTON_CLICK);
			_subtype = type;
			_page = page;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The page number for go to page events.
		 */
		public function get page():uint {
			return _page;
		}
		
		/**
		 * The subtype, more specifically the id of the button that was pressed.
		 */
		public function get subtype():String {
			return _subtype;
		}
		
	}
	
}