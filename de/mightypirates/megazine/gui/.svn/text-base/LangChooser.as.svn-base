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
	
	import de.mightypirates.utils.*;
	import flash.system.ApplicationDomain;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.utils.*;
	
	/**
	 * The GUI element that allows selecting the gui language, i.e. the language of
	 * elements part of MegaZine as well as title tooltip for elements.
	 * 
	 * @author fnuecke
	 */
	public class LangChooser extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Static variables (base flag images)
		// ----------------------------------------------------------------------------------- //
		
		/** Maps language ids to a bitmap with the flag for that language */
		private static var flags:Dictionary; // Bitmap
		
		/** Initialize the flags dictionary if not already done */
		private static function initFlags(lib:ILibrary):void {
			// Make flags array or return if it exists.
			if (flags != null) return;
			flags = new Dictionary();
			
			// Use short forms according to ISO 639-1
			var langs:Array = ["de", "en", "es", "fr", "hr", "id", "ip", "it", "ja", "pl", "ru", "th", "tr", "zh"];
			
			// Get the base image with all flags listed.
			var flagImgs:Bitmap = lib.getInstanceOf(LibraryConstants.FLAGS_INTERNAL) as Bitmap;
			
			// Generate the single flag images. The first one is always the "unknown" flag.
			var offset:Matrix = new Matrix();
			var currFlag:BitmapData = new BitmapData(14, 12, false);
			currFlag.draw(flagImgs, offset);
			flags["__unknown"] = currFlag;
			// Then parse the langs array and associate the flag images.
			for each (var langID:String in langs) {
				offset.tx -= 14;
				currFlag = new BitmapData(14, 12, false);
				currFlag.draw(flagImgs, offset);
				flags[langID] = currFlag;
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The background graphics */
		private var _bg:DisplayObject;
		
		/** Container for flags, for masking */
		private var _container:DisplayObjectContainer;
		
		/** The button of the current language */
		private var _current:DisplayObject;
		
		/** Displayed language buttons */
		private var _displayed:Dictionary; // SimpleButton
		
		/** If above pages open downwards, else upwards */
		private var _isAbovePages:Boolean;
		
		/** The localizer instance used */
		private var _localizer:Localizer;
		
		/** The mask for the flags... */
		private var _mask:Shape;
		
		/** When open this is the height of the list */
		private var _targetHeight:int;
		
		/** Should the list be open or closed? */
		private var _targetOpen:Boolean;
		
		/** Timer for opening or closing the list */
		private var _timer:Timer;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new language chooser control, displaying a flag button for each language
		 * found in the passed localizer and calling the setLanguage() method in the localizer
		 * for the appropriate language when a button is clicked.
		 * @param loc The localizer to use.
		 * @param lib Graphics library to draw graphics from (
		 */
		public function LangChooser(loc:Localizer, lib:ILibrary, isAbovePages:Boolean) {
			// Call the initializer for the base flag variable... if this has already been
			// called it cancels automatically.
			initFlags(lib);
			
			// Initialize vars
			_displayed = new Dictionary();
			_isAbovePages = isAbovePages;
			_localizer = loc;
			
			_localizer.addEventListener(LocalizerEvent.LANGUAGE_ADDED, onLangAdded);
			_localizer.addEventListener(LocalizerEvent.LANGUAGE_CHANGED, onLangChanged);
			
			_bg = lib.getInstanceOf(LibraryConstants.BACKGROUND);
			addChild(_bg);
			
			_mask = new Shape();
			_mask.graphics.beginFill(0xFF00FF);
			_mask.graphics.drawRect(0, 0, 18, 16);
			_mask.graphics.endFill();
			
			_container = new Sprite();
			_container.mask = _mask;
			_container.x = 1;
			_container.y = 1;
			
			_container.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_container.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			addChild(_mask);
			addChild(_container);
			
			_timer = new Timer(30);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			// Do the first update.
			onLangAdded();
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Handle a button click in terms of changing the language.
		 * @param	e
		 */
		private function onButtonClick(e:MouseEvent):void {
			_localizer.language = e.target.name;
		}
		
		/** New language added to the localizer */
		private function onLangAdded(e:LocalizerEvent = null):void {
			var langs:Array = _localizer.getAvailableLanguages();
			
			if (langs == null || langs.length == 0) {
				_bg.visible = false;
				return;
			}
			_bg.visible = true;
			_bg.height = 16;
			_bg.width = 18;
			var offset:int = 0;
			
			_targetHeight = 2 + langs.length * 14;
			
			for each (var langID:String in langs) {
				// Test if it exists, if yes reposition, else create new one.
				if (_displayed[langID]) {
					_displayed[langID].y = offset;
				} else {
					var imgID:String = langID;
					if (!flags[imgID]) {
						imgID = "__unknown";
					}
					
					// Create the button.
					var hitTestState:Shape = new Shape();
					hitTestState.graphics.beginFill(0xFF00FF);
					hitTestState.graphics.drawRect(0, 0, 16, 14);
					var upState:DisplayObject = new Bitmap(flags[imgID]);
					upState.x = 1;
					upState.y = 1;
					var overState:DisplayObject = new Bitmap(flags[imgID]);
					overState.x = 1;
					overState.y = 1;
					overState.filters = [new GlowFilter(0xFFFFFF, 0.5, 10, 8, 2, 1, true)];
					var downState:DisplayObject = new Bitmap(flags[imgID]);
					downState.x = 2;
					downState.y = 2;
					downState.filters = [new GlowFilter(0xFFFFFF, 0.5, 10, 8, 2, 1, true)];
					var btn:SimpleButton = new SimpleButton(upState, overState,
															downState, hitTestState);
					btn.y = offset;
					// Use the instance name to pass the language id
					btn.name = langID;
					btn.addEventListener(MouseEvent.CLICK, onButtonClick);
					_container.addChild(btn);
					
					_displayed[langID] = btn;
					
					// Create tooltip.
					new ToolTip(_localizer.getLangString(langID, "LNG_LANGUAGE_NAME"), btn);
				}
				
				if (offset == 0) {
					_current = _displayed[langID];
				}
				
				offset += _isAbovePages ? 14 : -14;
			}
			
			// If only one language is known do not display.
			visible = langs.length > 1;
			
			// Might be the newly added one is the current one...
			onLangChanged();
		}
		
		/** Current language of localizer changed */
		private function onLangChanged(e:LocalizerEvent = null):void {
			var newone:DisplayObject = _displayed[_localizer.language];
			if (newone) {
				if (_current) {
					_current.y = newone.y;
				}
				newone.y = 0;
				_current = newone;
			}
		}
		
		/** Mouse over, show all */
		private function onMouseOver(e:MouseEvent):void {
			_targetOpen = true;
			_timer.start();
		}
		
		/** Mouse out, collapse */
		private function onMouseOut(e:MouseEvent):void {
			_targetOpen = false;
			_timer.start();
		}
		
		/** Timer responsible for the smooth transitions when opening and collapsing */
		private function onTimer(e:TimerEvent):void {
			var target:int = _targetOpen ? _targetHeight : 16;
			// Interpolate new size
			_bg.height = (_bg.height + target) * 0.5;
			if (Math.abs(_bg.height - target) < 0.01) {
				_bg.height = target;
			}
			_mask.height = _bg.height - 2;
			if (!_isAbovePages) {
				_bg.y = 16 - _bg.height;
				_mask.y = 16 - _mask.height;
			}
		}
		
	}
	
}
