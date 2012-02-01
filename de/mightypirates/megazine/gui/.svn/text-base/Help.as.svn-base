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
	import de.mightypirates.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.text.*;
	
	/**
	 * The help box.
	 * 
	 * @author fnuecke
	 */
	public class Help extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Number of the currently displayed message */
		private var _currMessage:uint;
		
		/** Rectangle used to constrain the text when dragging it */
		private var _dragRect:Rectangle;
		
		/** The localizer used for localizing tooltips and texts */
		private var _localizer:Localizer;
		
		/** Ids of messages that may be displayed */
		private var _messages:Array; // String
		
		/** The scrollbar for scrolling messages that are too long */
		private var _scrollBar:VScrollBar;
		
		/** The text container to enable dragging */
		private var _textContainer:Sprite;
		
		/** Currently dragging the text or not */
		private var _textDragging:Boolean;
		
		/** The actual text field, for updating the text */
		private var _textField:TextField;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new help window.
		 * @param loc The localizer to use for the tooltips and messages.
		 * @param lib The library to use to get graphics from.
		 * @param buttonShow Buttons to show in the navigation (influences which messages get
		 * shown, and which don't as to not confuse the used).
		 * @param navbar Navigation bar visible or not.
		 */
		public function Help(loc:Localizer, lib:Library, buttonShow:Array, navbar:Boolean) {
			
			_localizer = loc;
			
			var bg:DisplayObject = lib.getInstanceOf(LibraryConstants.BACKGROUND);
			bg.width = 300;
			bg.height = 200;
			
			addChild(bg);
			
			var txtBG:DisplayObject = lib.getInstanceOf(LibraryConstants.BACKGROUND);
			txtBG.width = bg.width - 50;
			txtBG.height = bg.height - 50;
			txtBG.x = 25;
			txtBG.y = 25;
			addChild(txtBG);
			
			var btnClose:SimpleButton =
						lib.getInstanceOf(LibraryConstants.BUTTON_CLOSE) as SimpleButton;
			btnClose.x = bg.width - btnClose.hitTestState.width;
			btnClose.addEventListener(MouseEvent.CLICK, onClose);
			
			var btnPrev:SimpleButton =
						lib.getInstanceOf(LibraryConstants.BUTTON_ARROW_LEFT) as SimpleButton;
			btnPrev.y = bg.height - btnPrev.hitTestState.height;
			btnPrev.addEventListener(MouseEvent.CLICK, onPrevMessage);
			
			var btnNext:SimpleButton =
						lib.getInstanceOf(LibraryConstants.BUTTON_ARROW_RIGHT) as SimpleButton;
			btnNext.x = bg.width - btnPrev.hitTestState.width;
			btnNext.y = bg.height - btnPrev.hitTestState.height;
			btnNext.addEventListener(MouseEvent.CLICK, onNextMessage);
			
			addChild(btnClose);
			addChild(btnPrev);
			addChild(btnNext);
			
			var tt:ToolTip = new ToolTip("", btnClose);
			_localizer.registerObject(tt, "text", "LNG_HELP_CLOSE");
			tt = new ToolTip("", btnPrev);
			_localizer.registerObject(tt, "text", "LNG_HELP_PREV");
			tt = new ToolTip("", btnNext);
			_localizer.registerObject(tt, "text", "LNG_HELP_NEXT");
			
			// Drag bar
			var dragBar:Sprite = lib.getInstanceOf(LibraryConstants.BAR_BACKGROUND) as Sprite;
			dragBar.x = 50;
			dragBar.y = 10;
			dragBar.width = bg.width - 100;
			dragBar.height = 5;
			dragBar.buttonMode = true;
			dragBar.addEventListener(MouseEvent.MOUSE_DOWN, onWindowDragStart);
			addChild(dragBar);
			
			_textField = new TextField();
			_textField.defaultTextFormat = new TextFormat("Verdana, Helvetica, Arial, _sans",
														 "11", null, null, null, null,
														 null, null, TextFormatAlign.LEFT);
			_textField.selectable = false;
			_textField.textColor = 0xFFFFFF;
			_textField.x = 25;
			_textField.y = 25;
			_textField.width = bg.width - 65;
			_textField.autoSize = TextFieldAutoSize.CENTER;
			_textField.wordWrap = true;
			_textField.mouseEnabled = false;
			
			_textContainer = new Sprite();
			_textContainer.addChild(_textField);
			
			_textContainer.addEventListener(MouseEvent.MOUSE_DOWN, onTextDragStart);
			
			addChild(_textContainer);
			
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0xFF00FF);
			mask.graphics.drawRect(25, 25, bg.width - 65, bg.height - 50);
			mask.graphics.endFill();
			
			addChild(mask);
			
			_textContainer.mask = mask;
			
			_scrollBar = new VScrollBar(lib, 15, bg.height - 50);
			_scrollBar.y = 25;
			_scrollBar.x = bg.width - 40;
			_scrollBar.addEventListener(ScrollBarEvent.POSITION_CHANGED, onScrollBar);
			addChild(_scrollBar);
			
			_messages = new Array();
			if (buttonShow[4] && navbar) {
				_messages.push("LNG_HELP1");
			} else {
				_messages.push("LNG_HELP1B");
			}
			if (navbar) {
				_messages.push("LNG_HELP2");
			}
			_messages.push("LNG_HELP3");
			if (navbar) {
				if (buttonShow[0]) {
					_messages.push("LNG_HELP4");
				}
				if (buttonShow[3]) {
					_messages.push("LNG_HELP5");
				}
			}
			
			setMessage(0);
			
			addEventListener(Event.ADDED_TO_STAGE, registerListeners);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The displayed text, may be html formatted. This property is registered with the
		 * localizer, because it handles some post formatting and updating of the scrollbar
		 * visibility.
		 */
		public function set text(message:String):void {
			_textField.htmlText = message.replace(/<br\/>/g, "\n");
			_textContainer.y = 0;
			_dragRect = new Rectangle(0, 0, 0,
						Math.min(0, _textContainer.mask.height - _textContainer.height));
			var scrollable:Boolean = _textContainer.mask.height < _textContainer.height
			_textContainer.buttonMode = scrollable;
			_scrollBar.visible = scrollable;
			_textContainer.y = 0;
			_scrollBar.percent = 0;
		}
		
		/**
		 * Method used internally to set the current message. Updates linkage with the
		 * localizer. Handles "circular" switching, i.e. if a number too small is given the
		 * last message is shown, if a number too big is shown the first message is shown.
		 * @param num The number of the new message.
		 */
		private function setMessage(num:int):void {
			if (_messages.length < 1) return;
			if (num < 0) {
				_currMessage = _messages.length - 1;
			} else if (num >= _messages.length) {
				_currMessage = 0;
			} else {
				_currMessage = num;
			}
			_localizer.registerObject(this, "text", _messages[_currMessage]);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Event handling
		// ----------------------------------------------------------------------------------- //
		
		/** Register stage reliant listeners */
		private function registerListeners(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, registerListeners);
			stage.addEventListener(MouseEvent.MOUSE_UP, onTextDragStop);
			stage.addEventListener(MouseEvent.MOUSE_UP, onWindowDragStop);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onTextScroll);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMovement);
			addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
		}
		
		/** Kill stage reliant listeners */
		private function removeListeners(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onTextDragStop);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onWindowDragStop);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onTextScroll);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMovement);
		}
		
		/** Next button, show next message */
		private function onNextMessage(e:Event = null):void {
			setMessage(_currMessage + 1);
		}
		
		/** Prev button, show previous message */
		private function onPrevMessage(e:Event = null):void {
			setMessage(_currMessage - 1);
		}
		
		/** Mouse moved, update scrollbar if dragging the text */
		private function onMouseMovement(e:MouseEvent = null):void {
			if (_textDragging) {
				_scrollBar.percent =
						_textContainer.y / (_textContainer.mask.height - _textContainer.height);
			}
		}
		
		/** Scrollbar changed, update text position */
		private function onScrollBar(e:ScrollBarEvent):void {
			_textContainer.y = e.percent * (_textContainer.mask.height - _textContainer.height);
		}
		
		/** Start dragging the text */
		private function onTextDragStart(e:MouseEvent):void {
			_textDragging = true;
			_textContainer.startDrag(false, _dragRect);
		}
		
		/** Stop dragging the text */
		private function onTextDragStop(e:MouseEvent):void {
			_textContainer.stopDrag();
			_textDragging = false;
		}
		
		/** Start dragging the window */
		private function onWindowDragStart(e:MouseEvent):void {
			startDrag(false);
		}
		
		/** Stop dragging the window */
		private function onWindowDragStop(e:MouseEvent):void {
			stopDrag();
		}
		
		/** Text scroll via mousewheel. Update scrollbar if necessary */
		private function onTextScroll(e:MouseEvent):void {
			if (!visible || !_scrollBar.visible) return;
			if (e.delta > 0) {
				_textContainer.y += 15;
			} else {
				_textContainer.y -= 15;
			}
			_textContainer.y =
				Math.min(_dragRect.top, Math.max(_dragRect.bottom, _textContainer.y));
			_scrollBar.percent =
						_textContainer.y / (_textContainer.mask.height - _textContainer.height);
		}
		
		/** Close this window */
		private function onClose(e:MouseEvent):void {
			visible = false;
			dispatchEvent(new Event("closed"));
		}
		
	}
	
}
