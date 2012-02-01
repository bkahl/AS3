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
	
	import de.mightypirates.megazine.events.ScrollBarEvent;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	/**
	 * A scroll bar object.
	 * 
	 * @author fnuecke
	 */
	public class VScrollBar extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The background graphics, also used for jumps on click */
		private var _scrollBar:Sprite;
		
		/** The container for the button to make it draggable */
		private var _scrollButtonContainer:Sprite;
		
		/** Currently dragging or not */
		private var _scrollDragging:Boolean;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new scrollbar with graphics from the given library, the given width and
		 * the given height.
		 * @param lib Graphics library to use to load graphics.
		 * @param width Width of the scrollbar.
		 * @param height Height of the scrollbar.
		 */
		public function VScrollBar(lib:Library, width:uint = 15, height:uint = 100) {
			
			_scrollBar = lib.getInstanceOf(LibraryConstants.BAR_BACKGROUND) as Sprite;
			_scrollBar.width = width;
			_scrollBar.height = height;
			_scrollBar.alpha = 0.5;
			_scrollBar.buttonMode = true;
			_scrollBar.addEventListener(MouseEvent.MOUSE_DOWN, onScrollClick);
			
			var scrollBtn:SimpleButton =
						lib.getInstanceOf(LibraryConstants.BUTTON_SCROLL) as SimpleButton;
			_scrollButtonContainer = new Sprite();
			
			_scrollButtonContainer.addChild(scrollBtn);
			addChild(_scrollBar);
			addChild(_scrollButtonContainer);
			
			_scrollButtonContainer.addEventListener(MouseEvent.MOUSE_DOWN, onScrollDragStart);
			
			addEventListener(Event.ADDED_TO_STAGE, registerListeners);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/** The percentual value / position of the scrollbar */
		public function set percent(p:Number):void {
			_scrollButtonContainer.y = (_scrollBar.height - 15) * p;
		}
		
		/** The percentual value / position of the scrollbar */
		public function get percent():Number {
			return _scrollButtonContainer.y / (_scrollBar.height - 15);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Event handling
		// ----------------------------------------------------------------------------------- //
		
		/** Registers some stage reliant listeners when added to stage */
		private function registerListeners(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, registerListeners);
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrollDragStop);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMovement);
			addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
		}
		
		/** Remove stage reliant listeners when removed from stage */
		private function removeListeners(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollDragStop);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMovement);
		}
		
		/** Mouse movement handler for percent updating when dragging */
		private function onMouseMovement(e:MouseEvent = null):void {
			if (_scrollDragging) {
				var p:Number = _scrollButtonContainer.y / (_scrollBar.height - 15);
				dispatchEvent(new ScrollBarEvent(ScrollBarEvent.POSITION_CHANGED, p));
			}
		}
		
		/** Clicks on the scroll bar background, jump to that position */
		private function onScrollClick(e:MouseEvent):void {
			_scrollButtonContainer.y =
				globalToLocal(_scrollBar.localToGlobal(new Point(e.localX, e.localY))).y - 7.5;
			// Update position of the knob
			onScrollDragStart();
			onMouseMovement();
		}
		
		/** Begin dragging the position knob */
		private function onScrollDragStart(e:MouseEvent = null):void {
			_scrollDragging = true;
			_scrollButtonContainer.startDrag(false,
					new Rectangle(_scrollBar.x, _scrollBar.y, 0, _scrollBar.height - 15));
		}
		
		/** Stop dragging the position knob */
		private function onScrollDragStop(e:MouseEvent):void {
			_scrollButtonContainer.stopDrag();
			_scrollDragging = false;
		}
		
	}
	
}