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
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	/**
	 * Document class for the swf with the graphical elements.
	 * 
	 * @author fnuecke
	 */
	public class LibrarySWF extends MovieClip implements ILibrarySWF {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** Version number of the library */
		public const VERSION:Number = 1.034;
		
		/** Number of languages / flags in the flag image */
		private const langCount:uint = 14;
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Provides new instances of elements in the library.
		 * @param type The id of the element to get. Use constants from
		 * the LibraryConstants class.
		 */
		public function getInstanceOf(type:String):DisplayObject {
			
			switch (type) {
				case LibraryConstants.BACKGROUND:
					return new LibBackground();
					
				case LibraryConstants.BAR_BACKGROUND:
					return new LibBarBackground();
					
				case LibraryConstants.BUTTON_ARROW_LEFT:
					return new LibButtonArrowLeft();
					
				case LibraryConstants.BUTTON_ARROW_RIGHT:
					return new LibButtonArrowRight();
					
				case LibraryConstants.BUTTON_CLOSE:
					return new LibButtonClose();
					
				case LibraryConstants.BUTTON_FULLSCREEN:
					return new LibButtonFullscreen();
					
				case LibraryConstants.BUTTON_HELP:
					return new LibButtonHelp();
					
				case LibraryConstants.BUTTON_MUTE:
					return new LibButtonMute();
					
				case LibraryConstants.BUTTON_PAGE:
					return new LibButtonPage();
					
				case LibraryConstants.BUTTON_PAGE_FIRST:
					return new LibButtonPageFirst();
					
				case LibraryConstants.BUTTON_PAGE_LAST:
					return new LibButtonPageLast();
					
				case LibraryConstants.BUTTON_PAUSE:
					return new LibButtonPause();
					
				case LibraryConstants.BUTTON_PLAY:
					return new LibButtonPlay();
					
				case LibraryConstants.BUTTON_RESTORE:
					return new LibButtonRestore();
					
				case LibraryConstants.BUTTON_SCROLL:
					return new LibButtonScroll();
					
				case LibraryConstants.BUTTON_SETTINGS:
					return new LibButtonSettings();
					
				case LibraryConstants.BUTTON_UNMUTE:
					return new LibButtonUnmute();
				
				case LibraryConstants.BUTTON_ZOOM:
					return new LibButtonZoom();
					
				case LibraryConstants.CURSOR_TURN_LEFT:
					return new LibCursorTurnLeft();
					
				case LibraryConstants.CURSOR_TURN_RIGHT:
					return new LibCursorTurnRight();
					
				case LibraryConstants.CURSOR_ZOOM:
					return new LibCursorZoom();
					
				case LibraryConstants.FLAGS_INTERNAL:
					return new Bitmap(new LibFlagsInternal(14 * langCount, 12));
					
				case LibraryConstants.LOADING_BAR:
					return new LibLoadingBar();
					
				case LibraryConstants.LOADING_SIMPLE:
					return new LibLoadingSimple();
					
				case LibraryConstants.PAGE_NUMBER:
					return new LibPageNumberGraphics();
					
				case LibraryConstants.PASSWORD_FORM:
					return new LibPasswordFormGraphics();
					
				case LibraryConstants.SETTINGS:
					return new LibSettings();
					
				default:
					return null;
				
			}
		}
		
		/** Version number of the library */
		public function getVersion():Number {
			return VERSION;
		}
		
	}
	
}