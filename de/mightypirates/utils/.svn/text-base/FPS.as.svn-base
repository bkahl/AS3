/*
FPS - For simplified frames per second measurement
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
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	/**
	 * FPS
	 * 
	 * For easy frames per second measuring
	 * 
	 * @author fnuecke
	 * @version 1.0.3
	 */
	public class FPS extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Current accumulated average framerate */
		private var avg:Number = 30;
		
		/** Current absolute framerate (last measure) */
		private var cur:int = 0;
		
		/** Highest framerate ever */
		private var high:int = 0;
		
		/** Lowest framerate ever */
		private var low:int = 100;
		
		/** Maximum possible framerate (stage framerate) */
		private var max:int = 0;
		
		/** Output format of the values (see constructor documentation) */
		private var format:String;
		
		/** Textfield used to display current values */
		private var txt:TextField;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Constructor
		 * @param format Output format. Available variables are
		 * $avg for the average frame rate
		 * $cur for the current frame rate (last measurement)
		 * $high for the maximal frame rate reached
		 * $low for the minimal frame rate reached
		 * $max for the maximal frame rate possible
		 * @param width The width of the display object
		 * @param height The height of the display object
		 */
		public function FPS(format:String = "$cur/$max (LOW $low HIGH $high AVG $avg)") {
			
			// Copy the format
			this.format = format;
			
			// Create the text field
			txt = new TextField();
			txt.defaultTextFormat = new TextFormat("_sans", "8", null, null,
												   null, null, null, null, "center");
			txt.selectable = false;
			txt.background = true;
			txt.border = true;
			txt.height = 10;
			txt.autoSize = TextFieldAutoSize.LEFT;
			addChild(txt);
			
			// Start the timer doing the calculations each half second
			var t:Timer = new Timer(500);
			t.addEventListener(TimerEvent.TIMER, measure);
			t.start();
			
			// Add the event listener to the enter frame event to increase the counter
			addEventListener(Event.ENTER_FRAME, function(e:Event):void { cur++; });
			
			addEventListener(Event.ADDED_TO_STAGE, added);
			
		}
		
		/**
		 * Added to stage...
		 * @param e unused.
		 */
		private function added(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, added);
			x = -stage.stageWidth / 2;
			y = -stage.stageHeight / 2;
			stage.addEventListener(Event.RESIZE,
				function(e:Event):void {
					x = -stage.stageWidth / 2;
					y = -stage.stageHeight / 2;
				});
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Updater
		// ----------------------------------------------------------------------------------- //
		
		private function measure(e:TimerEvent):void {
			
			// Cur = cur * 2, because we check each half second (and minus one because else
			// we tend to get too high framerates, because we actually measure one tick after
			// half a second...
			cur = cur * 2 - 1;
			
			// Update display first (for cur)
			var tmp:String = format;
			tmp = tmp.replace("$avg", avg);
			tmp = tmp.replace("$cur", cur);
			tmp = tmp.replace("$high", high);
			tmp = tmp.replace("$low", low);
			tmp = tmp.replace("$max", max);
			txt.text = tmp;
			
			// Update values
			avg = Math.round((avg + cur) * 50) / 100;
			low = low > cur ? cur : low;
			high = high < cur ? cur : high;
			if (stage != null) max = stage.frameRate;
			cur = 0;
			
		}
		
	}
	
}
