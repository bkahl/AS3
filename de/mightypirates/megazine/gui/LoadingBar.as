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
	
	import de.mightypirates.utils.Localizer;
	import de.mightypirates.utils.LocalizerEvent;
	import flash.display.*;
	import flash.text.TextField;
	
	/**
	 * A loading bar with progress display and a label for text output.
	 * 
	 * @author fnuecke
	 */
	public class LoadingBar extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The actual bar, used for positioning the mask */
		private var _barMain:DisplayObject;
		
		/** The mask for the loading bar graphics (moved according to percent) */
		private var _barMask:Shape;
		
		/** The text field to output the status text to */
		private var _barText:TextField;
		
		/** Original width, sans mask */
		private var _baseWidth:Number;
		
		/** Localizer to get the "Loading... $1" text from */
		private var _localizer:Localizer;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new progress bar.
		 * @param lib Library from which to get the base graphics.
		 * @param format The base text format, if blank the set status will be displayed
		 * directly, if not the string $1 will be replaced with the status.
		 */
		public function LoadingBar(lib:ILibrary, loc:Localizer = null) {
			_localizer = loc;
			
			var gui:DisplayObjectContainer =
					lib.getInstanceOf(LibraryConstants.LOADING_BAR) as DisplayObjectContainer;
			_barMain = gui["barMain"] as DisplayObject;
			_barText = gui["barText"] as TextField;
			
			// Remember original width.
			_baseWidth = gui.width;
			
			// Create the mask
			_barMask = new Shape();
			_barMask.graphics.beginFill(0xFF00FF);
			_barMask.graphics.drawRect(0, 0, _barMain.width, _barMain.height);
			_barMask.graphics.endFill();
			_barMask.y = _barMain.y;
			_barMask.x = _barMain.x - _barMain.width;
			gui.addChild(_barMask);
			_barMain.mask = _barMask;
			addChild(gui);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Setter
		// ----------------------------------------------------------------------------------- //
		
		/** Set the percentual value */
		public function set percent(percent:Number):void {
			_barMask.x = _barMain.x - (1.0 - percent) * _barMain.width;
			if (_localizer != null) {
				_barText.text = _localizer.getLangString(_localizer.language,
										"LNG_LOADING_ZOOM").replace(/\$1/, Math.round(percent * 100));
			} else {
				_barText.text = String(Math.round(percent * 100)) + "%";
			}
		}
		
		/** The original width, sans mask */
		public function get baseWidth():Number {
			return _baseWidth;
		}
		
	}
	
}