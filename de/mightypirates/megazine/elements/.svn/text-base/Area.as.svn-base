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

package de.mightypirates.megazine.elements {
	
	import de.mightypirates.megazine.*;
	import de.mightypirates.megazine.events.*;
	import de.mightypirates.megazine.gui.ILibrary;
	import de.mightypirates.utils.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.*;
	import flash.utils.Timer;
	
	/**
	 * Area elements can be used to genereate tooltips and links anywhere on a page.
	 * 
	 * @author fnuecke
	 */
	public class Area extends AbstractElement {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Glow effect (faded in on mouseover if image is linked) */
		private var _glow:GlowFilter;
		
		/** Current target alpha for the glow */
		private var _targetGlowAlpha:Number = 0;
		
		/** The overlay */
		private var _area:Sprite;
		
		/** The timer for fading the glow effect */
		private var _timer:Timer;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new area element.
		 * @param mz   The MegaZine containing the page containing this element.
		 * @param lib  The library to obtain gui graphics from.
		 * @param page The page containing this element.
		 * @param even On the odd or on the even page?
		 * @param xml  The XML data for this element.
		 */
		public function Area(mz:IMegaZine, loc:Localizer, lib:ILibrary,
							 page:IPage, even:Boolean, xml:XML)
		{
			super(mz, loc, lib, page, even, xml);
		}
		
		override public function init():void {
			var sizex:Number = Helper.validateNumber(_xml.@width, 0);
			var sizey:Number = Helper.validateNumber(_xml.@height, 0);
			
			if (sizex > 0 && sizey > 0) {
				
				_area = new Sprite();
				_area.graphics.beginFill(0);
				_area.graphics.drawRect(0, 0, sizex, sizey);
				_area.graphics.endFill();
				_area.alpha = 0;
				
				// If it is a linked image, add a overlay (borderglow) on mouseover
				if (_xml.@url != undefined && Helper.validateBoolean(_xml.@useglow, true)) {
					var size:int = int(Math.min(sizex, sizey) / 10);
					_glow = new GlowFilter(0xFFFFFF, 0, size, size, 1,
										   BitmapFilterQuality.MEDIUM, true, true);
					_timer = new Timer(25);
					_timer.addEventListener(TimerEvent.TIMER,
						function(e:TimerEvent):void {
							if (Math.abs(_glow.alpha - _targetGlowAlpha) <= 0.1) {
								// Close enough, set it.
								_timer.stop();
								_glow.alpha = _targetGlowAlpha;
								if (_targetGlowAlpha == 0) {
									_area.alpha = 0;
									_area.filters = null;
									return;
								}
							} else {
								// Adjust the alpha.
								_glow.alpha += (_glow.alpha < _targetGlowAlpha) ? 0.1 : -0.1;
							}
							_area.filters = [_glow];
							_area.alpha = 1;
						});
					addEventListener(MouseEvent.MOUSE_OVER, onHover);
					addEventListener(MouseEvent.MOUSE_OUT, onLeave);
					addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
				}
				
				addChild(_area);
				
			} else {
				Logger.log("MegaZine Area",
						   "    Invalid or no size for 'area' object in page "
						   + (_page.getNumber(_even) + 1),
						   Logger.TYPE_WARNING);
			}
			
			super.init();
		}
		
		private function onHover(e:MouseEvent):void {
			_targetGlowAlpha = 1;
			_timer.start();
		}
		
		private function onLeave(e:MouseEvent):void {
			_targetGlowAlpha = 0;
			_timer.start();
		}
		
		private function removeListeners(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			try {
				_timer.stop();
				removeEventListener(MouseEvent.MOUSE_OVER, onHover);
				removeEventListener(MouseEvent.MOUSE_OUT, onLeave);
			} catch (e:Error) { }
		}
		
	}
	
}