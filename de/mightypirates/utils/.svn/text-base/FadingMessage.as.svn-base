/*
FadingMessage - a class for simplified creation of self fading text boxes.
Copyright (c) 2007-2008 Florian Nuecke

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package de.mightypirates.utils {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.text.*;
	import flash.utils.*;
	
	/**
	 * Class for simple creation of text boxes that fade out automatically.
	 * The element's center (the location set by the x and y properties) is at the top middle
	 * of the visible text box.
	 * @author fnuecke
	 * @version 1.02
	 */
	public class FadingMessage extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Currently visible message (to allow only one visible message at a time) */
		private static var _currentMessage:FadingMessage;
		
		
		/** The display object containing the fader message. */
		private var _container:DisplayObjectContainer;
		
		/** The display duration */
		private var _duration:Number;
		
		/** The maximum width of the message container */
		private var _maxWidth:Number;
		
		/** One shot or multishot timer? */
		private var _oneshot:Boolean;
		
		/** Time display started */
		private var _started:Number;
		
		/** The textfield used for displaying the text */
		private var _textField:TextField;
		
		/** Timer used for fading */
		private var _timer:Timer;
		
		/**
		 * Unique message? Two unique messages cannot be displayed at a time,
		 * the old one will be hidden first
		 */
		private var _unique:Boolean;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new fading message that first fades in, stays for the given duration,
		 * then fades out again.
		 * @param message The message to display. May be HTML formatted.
		 * @param container The container object in which to display the message.
		 * @param dispatcher The event dispatcher to observer.
		 * If left blank the message must manually be displayed by calling the "show" method.
		 * @param eventType The event for which to wait to show this message.
		 * @param duration How long to show the message in seconds (does not include time
		 * taken for fading).
		 * Negative value means auto (based on text length).
		 * @param oneshot Oneshot or multishot message.
		 * @param color Text color.
		 * @param maxWidth Maximum width of the message window. Height is determined
		 * automatically via wordwrap.
		 * @param unique Unique messages cannot be displayed simultaneously.
		 * If another unique message is visible when this one should be shown the
		 * old one gets hidden first.
		 */
		public function FadingMessage(message:String, container:DisplayObjectContainer,
									  dispatcher:IEventDispatcher, eventType:String,
									  oneshot:Boolean = true, color:uint = 0xFFFFFF,
									  maxWidth:uint = 300, unique:Boolean = true)
		{
			_container = container;
			_oneshot = oneshot;
			_unique = unique;
			_maxWidth = maxWidth;
			alpha = 0;
			
			// Create the textfield and set all the settings...
			_textField = new TextField();
			_textField.autoSize = TextFieldAutoSize.LEFT;
			_textField.defaultTextFormat = new TextFormat("Verdana, Helvetica, Arial, _sans",
														 "11", null, null, null, null,
														 null, null, TextFormatAlign.JUSTIFY);
			_textField.selectable = false;
			_textField.textColor = color;
			addChild(_textField);
			
			this.text = message;
			
			// Add a dropshadow (eyecandy ftw)
			filters = [new DropShadowFilter(2, 45, 0, 1, 3, 3, 0.5, BitmapFilterQuality.LOW)];
			
			// Setup timer
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			// Add event listener if given
			if (dispatcher != null && eventType != null) {
				dispatcher.addEventListener(eventType, eventFired);
			}
			
			// Click listener (click instantly hides)
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The total duration (including fading) this message is displayed. Note that this
		 * might change whenever the text does.
		 */
		public function get duration():uint {
			return (1900 + _duration) / 1000;
		}
		
		/** The (HTML formatted) text displayed by the tooltip. */
		public function get text():String {
			return _textField.text;
		}
		
		/** The (HTML formatted) text displayed by the tooltip. */
		public function set text(message:String):void {
			// Disable multiline and wordwrap, then set the text.
			_textField.wordWrap = false;
			_textField.multiline = false;
			_textField.htmlText = message.replace(/<br\/>/g, "\n");
			
			// Check if maxwidth is exceeded, if yes go to multiline mode.
			if (_textField.width > _maxWidth - 8) {
				_textField.multiline = true;
				_textField.width = _maxWidth - 8;
				_textField.wordWrap = true;
			}
			
			// Center position.
			_textField.x = -_textField.width * 0.5;
			_textField.y = 2;
			
			// Redraw stuff.
			redrawBackground();
			
			// Set display duration
			_duration = Math.sqrt(_textField.text.length) * 750;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Public
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Manually show the message.
		 */
		public function show():void {
			// If another message is visible remove it first
			if (_unique) {
				if (_currentMessage != null) {
					_currentMessage.hide();
				}
				_currentMessage = this;
			}
			// Show message
			_container.addChild(this);
			// Remember the current time and start the timer.
			_started = new Date().getTime();
			_timer.start();
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Event handling
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Event fired that triggers the display of this message.
		 */
		private function eventFired(e:Event):void {
			// If it's a oneshot message, kill the listener
			if (_oneshot) {
				(e.target as IEventDispatcher).removeEventListener(e.type, eventFired);
			}
			show();
		}
		
		/**
		 * Clicked, hide self.
		 */
		private function onClick(e:MouseEvent):void {
			if (_oneshot) {
				removeEventListener(MouseEvent.CLICK, onClick);
			}
			hide();
		}
		
		/**
		 * Timer for fading.
		 */
		private function onTimer(e:TimerEvent):void {
			// Check if fading should begin.
			var diff:Number = new Date().getTime() - _started;
			if (diff <= 400) {
				// Fade in.
				alpha = Math.min(1, 1 + (diff - 400) / 400);
				// Check how far we are.
				if (alpha > 0.99) {
					alpha = 1;
				}
			} else if (diff >= _duration + 400) {
				// Fade out.
				alpha = Math.max(0, (1 - (diff - _duration) / 1500));
				// Check how far we are. When done hide and stop the timer.
				if (alpha < 0.01) {
					hide();
				}
			} else {
				// Main visibility time.
				alpha = 1;
			}
		}
		
		/**
		 * Hide self by removing self from container.
		 */
		private function hide():void {
			_timer.stop();
			if (_unique && _currentMessage == this) {
				_currentMessage = null;
			}
			alpha = 0;
			_container.removeChild(this);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Rendering
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Redraw fade message background.
		 */
		private function redrawBackground():void {
			// Draw background
			graphics.clear();
			graphics.beginFill(0x000000, 0.6);
			graphics.lineStyle(1, 0xFFFFFF, 0.6);
			graphics.drawRect(-_textField.width * 0.5 - 2,
							  0,
							  _textField.width + 4,
							  _textField.height + 4);
			graphics.endFill();
		}
		
	}
	
}