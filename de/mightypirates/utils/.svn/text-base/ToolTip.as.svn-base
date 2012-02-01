/*
ToolTip - a class for easy creation of tooltips.
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
	 * The ToolTop class allows for a simple creation of tooltips for any object
	 * supporting the MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OVER and MouseEvent.MOUSE_OUT
	 * events.
	 * 
	 * @version 1.0.6
	 * @author fnuecke
	 */
	public class ToolTip extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** Use centered coordinate system, i.e. the stage spans equally in all directions */
		public static const COORDINATE_CENTERED:String = "coord_center";
		
		/**
		 * Use a top left aligned coordinate system, i.e. the stage only spans towards the
		 * bottom and right.
		 */
		public static const COORDINATE_TOP_LEFT:String = "coord_topleft";
		
		/** Invert pointer direction on the x axis */
		private static const INVERT_X:uint = 1;
		
		/** Invert pointer direction on the y axis */
		private static const INVERT_Y:uint = 2;
		
		
		// ----------------------------------------------------------------------------------- //
		// Static Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Maps display objects to their tooltips */
		private static var ttlist:Dictionary = new Dictionary(true);
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Use a centralized or top left aligned coordinate system */
		private var _coordType:Boolean = false;
		
		/** The timer responsible for fading */
		private var _fadeTimer:Timer;
		
		/** Current inversion states for x and y (used to only redraw background when needed) */
		private var _invertState:uint;
		
		/** Maximum width of the tooltip */
		private var _maxWidth:Number;
		
		/** The object this tooltip belongs to */
		private var _object:DisplayObject;
		
		/** The textfield used to display the tooltip text */
		private var _textField:TextField;
		
		/** The timer used to delay the tooltip displaying */
		private var _delayTimer:Timer;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new tooltip for the given object.
		 * @param text The tooltip text to display.
		 * @param object The object for which the tooltip should be shown.
		 * @param delay After how many milliseconds to show the tooltip.
		 * @param maxwidth The maximum width of the tooltip. If it exceeds that width,
		 * wordwrap and multiline get activated.
		 * @param fadetime Over how many milliseconds to fade the tooltip in and out.
		 * @param coords The type of coordinates to use, see constants.
		 */
		public function ToolTip(text:String, object:DisplayObject,
								delay:int = 400, maxWidth:Number = 275,
								fadeTime:int = 200, coords:String = COORDINATE_CENTERED)
		{
			
			// Remember the object to allow killing the tooltip later on
			_object = object;
			
			// Store coordinate type
			_coordType = coords == COORDINATE_TOP_LEFT;
			
			// Remember maxwidth
			_maxWidth = maxWidth;
			
			// Setup self.
			mouseEnabled = false;
			// Add a dropshadow (eyecandy ftw)
			filters = [new DropShadowFilter(2, 45, 0, 1, 3, 3, 0.5,
													BitmapFilterQuality.LOW)];
			
			// Create the textfield and set all the settings...
			_textField = new TextField();
			_textField.autoSize = TextFieldAutoSize.LEFT;
			_textField.defaultTextFormat = new TextFormat("Verdana, Helvetica, Arial, _sans",
														 "11", null, null, null, null,
														 null, null, TextFormatAlign.JUSTIFY);
			// mouseEnabled to false, else the tooltip blocks the cursor, causing a mouseout
			// everytime the tooltip becomes visible.
			_textField.mouseEnabled = false;
			_textField.selectable = false;
			_textField.textColor = 0xFFFFFF;
			// The "padding" left and right.
			_textField.x = 4;
			// Then add the actual text.
			addChild(_textField);
			this.text = text;
			
			// Create the timer, for delayed tooltip display.
			if (delay > 0) {
				_delayTimer = new Timer(delay, 1);
				_delayTimer.addEventListener(TimerEvent.TIMER, onDelayTimer);
			}
			
			// Create the timer for fading the tooltip.
			if (fadeTime > 0) {
				// Create the timer
				_fadeTimer = new Timer(50);
				// The listener. Checks if we're as good as done, if yes set the alpha to the
				// target alpha instantly, stop the timer and if the alpha is 0 remove from
				// stage. Else just update the alpha.
				_fadeTimer.addEventListener(TimerEvent.TIMER, onFadeTimer);
			}
			
			// Destroy old one if it existed and store new one
			destroyForDisplayObject(_object);
			ttlist[_object] = this;
			
			// Register event listeners.
			_object.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			_object.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_object.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_object.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			
			// Cleanup
			_object.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void { destroy(); } );
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/** The text displayed by the tooltip. */
		public function get text():String {
			return _textField.text;
		}
		
		/** The text displayed by the tooltip. */
		public function set text(message:String):void {
			// Disable multiline and wordwrap, then set the text.
			_textField.wordWrap = false;
			_textField.multiline = false;
			_textField.text = message;
			
			// Check if maxwidth is exceeded, if yes go to multiline mode.
			if (_textField.width > _maxWidth - 8) {
				_textField.multiline = true;
				_textField.width = _maxWidth - 8;
				_textField.wordWrap = true;
			}
			
			// Redraw stuff.
			redrawBackground();
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Event handlers
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Fade in delay timer tick.
		 * @param	e
		 */
		private function onDelayTimer(e:TimerEvent):void {
			try {
				redrawBackground();
				_object.stage.addChild(this);
				if (_fadeTimer != null) {
					alpha = 0;
					_fadeTimer.start();
				}
			} catch (ex:Error) {}
		}
		
		/**
		 * Fade in timer tick.
		 * @param	e
		 */
		private function onFadeTimer(e:TimerEvent):void {
			alpha += 10 / _fadeTimer.delay;
			if (alpha > 0.9) {
				alpha = 1;
				_fadeTimer.stop();
			}
		}
		
		/**
		 * Mouse move event, used to reposition the tooltip next to the cursor.
		 * @param e MouseEvent object. Used to get the new position for the textfield.
		 */
		private function onMove(e:MouseEvent):void {
			var invertX:Boolean = false;
			if (_coordType) {
				invertX = e.stageX + width - _object.stage.stageWidth > 0;
			} else {
				invertX = e.stageX + width - _object.stage.stageWidth / 2 > 0;
			}
			if (invertX) {
				x = e.stageX - width;
			} else {
				x = e.stageX;
			}
			var invertY:Boolean = false;
			if (_coordType) {
				invertY = e.stageY + 24 + height - _object.stage.stageHeight > 0;
			} else {
				invertY = e.stageY + 24 + height - _object.stage.stageHeight / 2 > 0;
			}
			if (invertY) {
				y = e.stageY - height;
			} else {
				y = e.stageY + 24;
			}
			if ((_invertState & INVERT_X) > 0 != invertX || (_invertState & INVERT_Y) > 0 != invertY) {
				_invertState = (invertX ? 1 : 0) + (invertY ? 2 : 0);
				if (parent != null) {
					redrawBackground();
				}
			}
		}
		
		/**
		 * When the parent gets removed from stage remove self, too.
		 * @param e Event object. Not used.
		 */
		private function onRemoved(e:Event):void {
			onOut(null);
		}
		
		/**
		 * Called when the mouse exits the object in question.
		 * @param e MouseEvent object. Not used.
		 */
		private function onOut(e:MouseEvent):void {
			_delayTimer.stop();
			try {
				if (_object.stage.contains(this)) {
					_object.stage.removeChild(this);
				}
			} catch (ex:Error) {}
		}
		
		/**
		 * Called when the mouse enters the object in question.
		 * @param e MouseEvent object. Not used.
		 */
		private function onOver(e:MouseEvent):void {
			_delayTimer.reset();
			onMove(e);
			if (_delayTimer != null) {
				_delayTimer.start();
			} else {
				try {
					redrawBackground();
					_object.stage.addChild(this);
					if (_fadeTimer != null) {
						alpha = 0;
						_fadeTimer.start();
					}
				} catch (ex:Error) {}
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Rendering
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Redraw tooltip background.
		 */
		private function redrawBackground():void {
			graphics.clear();
			graphics.beginFill(0x000000, 0.6);
			graphics.lineStyle(1, 0xFFFFFF, 0.6);
			graphics.drawRect(0, 0, _textField.width + _textField.x * 2, _textField.height);
			graphics.endFill();
			
			graphics.beginFill(0xFFFFFF, 0.5);
			graphics.lineStyle(NaN);
			
			if ((_invertState & INVERT_X) > 0) {
				// right
				if ((_invertState & INVERT_Y) > 0) {
					// bottom
					graphics.moveTo(width, height);
					graphics.lineTo(width - 5, height);
					graphics.lineTo(width, height - 5);
				} else {
					// top
					graphics.moveTo(width, 0);
					graphics.lineTo(width - 5, 0);
					graphics.lineTo(width, 5);
				}
			} else {
				// left
				if ((_invertState & INVERT_Y) > 0) {
					// bottom
					graphics.moveTo(0, height);
					graphics.lineTo(5, height);
					graphics.lineTo(0, height - 5);
				} else {
					// top
					graphics.moveTo(0, 0);
					graphics.lineTo(5, 0);
					graphics.lineTo(0, 5);
				}
			}
			
			graphics.endFill();
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// "Deconstructor"
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Destroys the tooltip by removing the event listeners for mouse events
		 * from the object.
		 */
		public function destroy():void {
			_object.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			_object.removeEventListener(MouseEvent.ROLL_OUT, onOut);
			_object.removeEventListener(MouseEvent.ROLL_OVER, onOver);
			_object.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			if (ttlist[_object] != null) {
				delete ttlist[_object];
			}
		}
		
		/**
		 * Static one, based on given displayobject.
		 * @param object The object for which to destroy the tooltip.
		 */
		public static function destroyForDisplayObject(object:DisplayObject):void {
			if (ttlist[object] != null) {
				(ttlist[object] as ToolTip).destroy();
				delete ttlist[object];
			}
		}
		
	}
	
}