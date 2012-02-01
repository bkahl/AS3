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
	 * Event type used by megazine.
	 * 
	 * @author fnuecke
	 */
	public class MegaZineEvent extends Event {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** Event raised when a child element of this page completes initializing */
		public static const ELEMENT_COMPLETE:String = "element_complete";
		
		/** Fired to inform elements to mute themselves */
		public static const MUTE:String             = "mute";
		
		/** Even page becomes invisible */
		public static const INVISIBLE_EVEN:String   = "invisible_even";
		
		/** Odd page becomes invisible */
		public static const INVISIBLE_ODD:String    = "invisible_odd";
		
		/** Fired when the library was loaded successfully */
		public static const LIBRARY_COMPLETE:String = "library_complete";
		
		/** Fired when there is an error while loading the library */
		public static const LIBRARY_ERROR:String    = "library_error";
		
		/** Fired when the current page changes */
		public static const PAGE_CHANGE:String      = "page_change";
		
		/** Event raised when a page completes loading its elements */
		public static const PAGE_COMPLETE:String    = "page_complete";
		
		/** Fired when the correct password is entered in the password form */
		public static const PASSWORD_CORRECT:String = "password_correct";
		
		/** Fired when slideshow starts */
		public static const SLIDE_START:String      = "slide_start";
		
		/** Fired when slideshow stops */
		public static const SLIDE_STOP:String       = "slide_stop";
		
		/** Fired when the status changes */
		public static const STATUS_CHANGE:String    = "status_change";
		
		/** Fired to inform elements to unmute themselves */
		public static const UNMUTE:String           = "unmute";
		
		/** Even page becomes visible */
		public static const VISIBLE_EVEN:String     = "visible_even";
		
		/** Odd page becomes visible */
		public static const VISIBLE_ODD:String      = "visible_odd";
		
		/** Navigated to another page via zoom */
		public static const ZOOM_CHANGED:String     = "zoom_changed";
		
		/** Zoom mode was closed */
		public static const ZOOM_CLOSED:String      = "zoom_closed";
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Megazine state when event was fired */
		private var _state:String;
		
		/** Previous state */
		private var _prevstate:String;
		
		/** Page changed to when event was fired */
		private var _page:int;
		
		/** Message that was logged */
		private var _msg:String;
		
		/** For page turn completions (page state), which way it was turning */
		private var _ltr:Boolean;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new megazine event.
		 * @param type The type of the event
		 * @param curPage The current page, only used for page change events.
		 * @param msg The message that was logged or the new megazine state, only used for
		 * message events or state change events, respectively.
		 * @param prevstate The previous state before changing to this one (only for status
		 * change)
		 */
		public function MegaZineEvent(name:String, _page:int = 0,
									  _newstate:String = "", _prevstate:String = "",
									  _ltr:Boolean = false) {
			super(name);
			this._page = _page;
			this._state = _newstate;
			this._prevstate = _prevstate;
			this._ltr = _ltr;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The page changed to when firing this event. Only used for page change events.
		 */
		public function get page():int {
			return _page;
		}
		
		/**
		 * The message that was logged. Only used for message events.
		 */
		public function get message():String {
			return _msg;
		}
		
		/**
		 * The state when firing this event when used for status change events.
		 * The loading state when firing this event when used for page completion events.
		 */
		public function get state():String {
			return _state;
		}
		
		/**
		 * The state prior to the state change when used for status change events.
		 * The previous loading state when firing this event when used for page
		 * completion events.
		 */
		public function get prevstate():String {
			return _prevstate;
		}
		
		/**
		 * The page's turning direction. Only used for page status change events.
		 */
		public function get leftToRight():Boolean {
			return _ltr;
		}
		
	}
	
}