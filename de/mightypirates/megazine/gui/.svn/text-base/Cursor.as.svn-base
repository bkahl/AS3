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
	
	import de.mightypirates.utils.Logger;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	
	/**
	 * Handles cursor display (allows for different cursor images in
	 * a centralized fashion).
	 * 
	 * @author fnuecke
	 */
	public class Cursor {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** Default mouse cursor */
		public static const DEFAULT:String    = "";
		
		/** Cursor hinting for the possibility to turn left */
		public static const TURN_LEFT:String  = "turn_left";
		
		/** Cursor hinting for the possibility to turn right */
		public static const TURN_RIGHT:String = "turn_right";
		
		/** Cursor hinting for zoom possibility */
		public static const ZOOM:String       = "zoom";
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** ID of the currently used cursor */
		private static var _current:String = "";
		
		/** List of cursor images */
		private static var _cursors:Dictionary = new Dictionary(); // DisplayObject
		
		/** Current position of the cursor */
		private static var _position:Point = new Point();
		
		/** Current cursor visibility */
		private static var _visible:Boolean = true;
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Initialize with graphics from the given library, in the given container.
		 * @param lib The library to get the graphics from.
		 * @param container The container into which to render the cursors.
		 * @param handCursor Use hand cursor for left and right turning instead.
		 */
		public static function init(lib:ILibrary, container:DisplayObjectContainer,
									handCursor:Boolean):void
		{
			
			try {
				
				_cursors[ZOOM] = lib.getInstanceOf(LibraryConstants.CURSOR_ZOOM);
				_cursors[ZOOM].visible = false;
				_cursors[ZOOM].mouseEnabled = false;
				container.addChild(_cursors[ZOOM]);
				
				if (!handCursor) {
					_cursors[TURN_LEFT] = lib.getInstanceOf(LibraryConstants.CURSOR_TURN_LEFT);
					_cursors[TURN_LEFT].visible = false;
					_cursors[TURN_LEFT].mouseEnabled = false;
					container.addChild(_cursors[TURN_LEFT]);
					
					_cursors[TURN_RIGHT] = lib.getInstanceOf(LibraryConstants.CURSOR_TURN_RIGHT);
					_cursors[TURN_RIGHT].visible = false;
					_cursors[TURN_RIGHT].mouseEnabled = false;
					container.addChild(_cursors[TURN_RIGHT]);
				}
				
			} catch (e:Error) {
				Logger.log("MegaZine", "Error getting cursor images: " + e.toString(),
						   Logger.TYPE_WARNING);
			}
			
			container.addEventListener(MouseEvent.MOUSE_MOVE, updatePosition);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Gets the current type of the cursor.
		 */
		public static function get cursor():String {
			return _current;
		}
		
		/**
		 * Sets the type of the cursor.
		 */
		public static function set cursor(id:String):void {
			if (id != _current) {
				if (_current && _cursors[_current]) {
					_cursors[_current].visible = false;
				}
				_current = id;
				if (_cursors[_current]) {
					_cursors[_current].x = _position.x;
					_cursors[_current].y = _position.y;
				}
				(_current && _cursors[_current]) ? Mouse.hide() : Mouse.show();
				visible = true;
			}
		}
		
		/**
		 * Gets visibility of the cursor.
		 */
		public static function get visible():Boolean {
			return _visible;
		}
		
		/**
		 * Sets visibility of the cursor.
		 */
		public static function set visible(visible:Boolean):void {
			_visible = visible;
			if (_current) {
				if (_cursors[_current]) {
					_cursors[_current].visible = _visible;
				} else {
					_visible ? Mouse.show() : Mouse.hide();
				}
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Event handler
		// ----------------------------------------------------------------------------------- //
		
		/** Handles mouse movement and repositions image of the current cursor image */
		private static function updatePosition(e:MouseEvent):void {
			_position.x = e.stageX;
			_position.y = e.stageY;
			if (_current && _cursors[_current]) {
				_cursors[_current].x = e.stageX;
				_cursors[_current].y = e.stageY;
			}
		}
		
	}
	
}