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
	
	import de.mightypirates.megazine.events.*;
	import de.mightypirates.megazine.gui.*;
	import de.mightypirates.utils.Helper;
	import de.mightypirates.utils.Localizer;
	import de.mightypirates.utils.Logger;
	import flash.display.*;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import de.mightypirates.megazine.*;
	
	/**
	 * Not actually abstract, but whatever. Parent class to all integrated elements.
	 * Must extend MovieClip for external classes (which use classes extending this
	 * class as documentclass, and document classes must extend movieclip...)
	 * 
	 * @author fnuecke
	 */
	public class AbstractElement extends MovieClip {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** On the odd or on the even page */
		internal var _even:Boolean;
		
		/** Library to get gui graphics from */
		internal var _library:ILibrary;
		
		/** The loading graphics that should be displayed while the element is loading */
		internal var _loading:DisplayObject;
		
		/** Localizer class used to bind strings to text display */
		internal var _localizer:Localizer;
		
		/** The MegaZine containing this element */
		internal var _mz:IMegaZine;
		
		/** The Page containing this element */
		internal var _page:IPage;
		
		/** XML data for this object */
		internal var _xml:XML;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Making it private so it cannot be instantiated is impossible in AS3, sadly.
		 * @param mz   The MegaZine containing the page containing this element.
		 * @param page The page containing this element.
		 * @param even On the odd or on the even page?
		 * @param xml  The XML data for this element.
		 */
		public function AbstractElement(mz:IMegaZine = null, loc:Localizer = null,
										lib:ILibrary = null, page:IPage = null,
										even:Boolean = false, xml:XML = null)
		{
			Constructor(mz, loc, lib, page, even, xml);
		}
		
		/**
		 * Delayed loading of the loading graphics. This is for external elements (because
		 * those cannot pass the required variables to the actual constructor, but instead
		 * need to initialize it delayed.
		 */
		public function Constructor(mz:IMegaZine, loc:Localizer, lib:ILibrary,
									page:IPage, even:Boolean, xml:XML):AbstractElement
		{
			_mz = mz;
			_page = page;
			_xml = xml;
			_even = even;
			_library = lib;
			_localizer = loc;
			
			if (_library != null && _xml != null) {
				try {
					_loading = _library.getInstanceOf(LibraryConstants.LOADING_SIMPLE);
				} catch (e:Error) {
					Logger.log("MegaZine Element",
							   "Failed getting loading graphics: " + e.toString(),
							   Logger.TYPE_WARNING);
				}
				
				_loading.x = Helper.validateNumber(_xml.@width, 0) * 0.5;
				_loading.y = Helper.validateNumber(_xml.@height, 0) * 0.5;
				if (_loading.x == 0) {
					_loading.x = _loading.width * 0.5;
				}
				if (_loading.y == 0) {
					_loading.y = _loading.height * 0.5;
				}
				
				addChild(_loading);
			}
			return this;
		}
		
		/**
		 * Must be overridden by child classes.
		 */
		public function init():void {
			removeChild(_loading);
			dispatchEvent(new MegaZineEvent(MegaZineEvent.ELEMENT_COMPLETE,
											_page.getNumber(_even)));
		}
		
	}
	
}