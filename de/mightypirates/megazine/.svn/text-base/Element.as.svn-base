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

package de.mightypirates.megazine {
	
	import de.mightypirates.megazine.gui.ILibrary;
	import de.mightypirates.megazine.elements.*;
	import de.mightypirates.megazine.events.*;
	import de.mightypirates.utils.*;
	import flash.utils.Dictionary;
	
	import flash.events.*;
	import flash.display.*;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * Wrapper for actual element display objects, handles loading/unloading the element.
	 * Also handles possibly required reloading on language changes. In that case the element
	 * is unloaded and attached to the element loader queue.
	 * This class is used as a static refernce to an element defined in xml. It is only created
	 * once in the lifetime of a MegaZine object, contrary to the actual elements, which might
	 * be unloaded an reloaded as necessary (e.g. when the containing page is not within valid
	 * range and needs to be unloaded to free memory).
	 * 
	 * @author fnuecke
	 */
	internal class Element extends EventDispatcher {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * List of internal elements, i.e. of elements that are not loaded from swf files but
		 * instantiated from classes.
		 */
		private static const INTERNAL_ELEMENTS:Array = new Array("area", "img", "nav",
																 "snd", "txt");
		
		/** The belonging classes - must be at the same position in the array. */
		private static const INTERNAL_CLASSES:Array = new Array(Area, Image, Navigation,
																Audio, Text);
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The actual element this wrapper represents.
		 * May be null in which case the element is not currently loaded.
		 */
		private var _element:AbstractElement;
		
		/** Library for graphics */
		private var _library:ILibrary;
		
		/** The loader object used for loading external elements */
		private var _loader:Loader;
		
		/** The localizer used for localizing strings */
		private var _localizer:Localizer;
		
		/** The main owning megazine */
		private var _mz:MegaZine;
		
		/** Element is on an even or on an odd page */
		private var _onEvenPage:Boolean;
		
		/** The page containing the element */
		private var _page:IPage;
		
		/** Unique id for this element't title */
		private var _uid:String
		
		/** The XML data for this element */
		private var _xml:XML;
		
		/** The last used elementloader (set by the loader) */
		internal var elementLoader:ElementLoader;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new element wrapper.
		 * @param	mz
		 * @param	loc
		 * @param	lib
		 * @param	xml
		 * @param	page
		 * @param	even
		 */
		public function Element(mz:MegaZine, loc:Localizer, lib:ILibrary,
									   xml:XML, page:IPage, even:Boolean) {
			_onEvenPage = even;
			_page = page;
			_xml = xml;
			_mz = mz;
			_localizer = loc;
			_library = lib;
			
			// Generate unique id
			_uid = "element_" + _xml.name() + "_title_" + (new Date().time).toString()
					+ int(Math.random() * 1000000).toString();
			
			// Localization stuff... set current language if possible, register listener.
			if (_xml.elements("src").length() > 0) {
				// Check if english is a given child. If yes ignore the actual src attribute;
				// if no add the actual src attribute as english to the children.
				var attribSrc:String = Helper.validateString(_xml.@src, "");
				if (attribSrc != "") {
					var defLang:String = loc.defaultLanguage;
					var defExists:Boolean = false;
					for each (var src:XML in _xml.elements("src")) {
						var langID:String = Helper.validateString(src.@lang, "");
						if (langID == defLang) {
							defExists = true;
							break;
						}
					}
					// Not found, append.
					if (!defExists) {
						_xml.appendChild("<src lang=\"" + defLang + "\">" + attribSrc + "</src>");
					}
				}
				setSourceToLanguage(_localizer.language);
				_localizer.addEventListener(LocalizerEvent.LANGUAGE_CHANGED, onLanguageChange);
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Properties
		// ----------------------------------------------------------------------------------- //
		
		/** Gets the actual element associated with this one. May be null if not loaded. */
		internal function get element():AbstractElement {
			return _element;
		}
		
		/** Tells whether this element is on an even page or not. */
		internal function get even():Boolean {
			return _onEvenPage;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Load the element. If the element is already loading, loading is cancelled
		 * and restarted.
		 */
		public function load():void {
			// First unload...
			unload();
			
			// Element type / name
			var name:String = _xml.name();
			
			Logger.log("MegaZine Element", "    Page " + _page.getNumber(_onEvenPage) + ": " +
					   "Loading Element of type '" + name + "'.");
			
			// Check if it's a built in element.
			var id:int = INTERNAL_ELEMENTS.indexOf(name);
			if (id >= 0) {
				
				try {
					// Create the object from a class and set it up
					_element = new INTERNAL_CLASSES[id](_mz, _localizer, _library,
														_page, _onEvenPage, _xml);
					setupElement();
				} catch (e:Error) {
					dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false,
									"Dynamic instantiation for element of type '" + name
									+ "' failed: " + e.message));
				}
				
			} else {
				// No, load the element swf file
				try {
					_loader = new Loader();
					_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
					_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
					_loader.load(new URLRequest(_mz.getAbsPath("elements/" + name + ".swf")));
				} catch (e:SecurityError) {
					dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false,
									"Loading of element of type '" + name
									+ "' failed (security error)."));
				}
			}
			
		}
		
		/** Error loading external element */
		private function onError(e:IOErrorEvent):void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader = null;
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false,
							"Failed loading external element of type '" + _xml.name() + "'."));
		}
		
		/** Done loading external element */
		private function onLoaded(e:Event):void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader = null;
			// Setup and call the init function if it exists
			try {
				// Initialize the loaded element and set it up
				_element = (e.target.loader.getChildAt(0) as AbstractElement).Constructor(
								_mz, _localizer, _library, _page, _onEvenPage, _xml);
				setupElement();
			} catch (ex:Error) {
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false,
								"Loaded element of type '" + _xml.name() + "' was invalid."));
			}
		}
		
		/** Basic setup like positioning and tooltip */
		private function setupElement():void {
			
			// Element type / name
			var name:String = _xml.name();
			
			// Add listener to wait for loading completion
			_element.addEventListener(MegaZineEvent.ELEMENT_COMPLETE, onElementLoaded);
			
			// Position / title / link
			_element.x = Helper.validateInt(_xml.@left, 0);
			_element.y = Helper.validateInt(_xml.@top, 0);
			
			// Images get a special treatment here, because of the zoom functionality.
			// The have to take care of the linking themselves, because the zoom
			// button has to be above the area that handles the link. Thus they
			// also have to take care of the title.
			if (name != "img") {
				var url:String = Helper.validateString(_xml.@url, "");
				
				var numLangs:uint = 0;
				// Check for title attribute. Handle it as a default entry.
				var title:String = Helper.validateString(_xml.@title, null);
				if (title != null && title != "") {
					_localizer.registerString(null, _uid, title);
					numLangs++;
				}
				// Then check for child title elements.
				for each (var lang:XML in _xml.elements("title")) {
					var langID:String = Helper.validateString(lang.@lang, "");
					if (langID != "" && lang.toString() != "") {
						_localizer.registerString(langID, _uid, lang.toString());
						numLangs++;
					}
				}
				// Create tooltip if we have a title.
				if (numLangs > 0) {
					// Create blank tooltip
					var tt:ToolTip = new ToolTip("", _element);
					_localizer.registerObject(tt, "text", _uid);
				}
				
				// Create a link from the element
				if (url != "") {
					url = _mz.getAbsPath(url, ["http://", "https://", "file://",
											   "ftp://", "mailto:", "anchor:"]);
					var target:String = Helper.validateString(_xml.@target, "_blank");
					// Check if a title was not defined, if so display the link address
					if (title == null && numLangs == 0) {
						new ToolTip(url, _element);
					}
					_element.buttonMode = true;
					_element.addEventListener(MouseEvent.CLICK,
						function(e:MouseEvent):void {
							// Check if it is a link to an anchor
							if (url.search("anchor:") == 0) {
								// Internal link
								_mz.gotoAnchor(url.slice(7));
							} else {
								// External link
								try {
									navigateToURL(new URLRequest(url), target);
								} catch (ex:Error) {
									Logger.log("MegaZine Page", "Error navigating to url '"
												+ Helper.trimString(url, 30) + "': "
												+ ex.toString(), Logger.TYPE_WARNING);
								}
							}
						});
				}
				
			} else {
				// If it's an image check if it has a hires version and if it should be
				// registered with a gallery
				var hiresPath:String = Helper.validateString(_xml.@hires, "");
				var galleryName:String = Helper.validateString(_xml.@gallery, "");
				if (hiresPath != "" && galleryName != "") {
					hiresPath = _mz.getAbsPath(hiresPath);
					var pos:uint = _mz.getGalleryData(galleryName, _page.getNumber(_onEvenPage),
													  hiresPath);
					(_element as Image).setGalleryData(galleryName, pos);
				}
			}
			
			// Initialize it to trigger loading
			_element.init();
			
		}
		
		/** Loading of the actual element complete, forward the event */
		private function onElementLoaded(e:MegaZineEvent):void {
			_element.removeEventListener(MegaZineEvent.ELEMENT_COMPLETE, onElementLoaded);
			dispatchEvent(new MegaZineEvent(e.type, e.page));
		}
		
		/** Used for elements to reload content if localized versions exist */
		private function onLanguageChange(e:LocalizerEvent):void {
			switch (_xml.name().toString()) {
				case "img":
				case "vid":
				case "snd":
					// Only for supported elements. Set the language, then reload, but only if
					// the element is currently loaded.
					if (setSourceToLanguage(_localizer.language) && _element != null) {
						if (elementLoader != null) {
							unload();
							elementLoader.addElement(this, _page.getPageVisible(_onEvenPage));
						} else {
							// Load directly
							load();
						}
					}
					break;
			}
		}
		
		/**
		 * Helper method trying to set the source attribute to the child element that holds the
		 * url for the current language.
		 * @return true if it was changed, else false.
		 */
		private function setSourceToLanguage(lang:String):Boolean {
			var defLang:String = _localizer.defaultLanguage;
			var defFallback:String = "";
			if (_xml.elements("src").length() > 0) {
				for each (var src:XML in _xml.elements("src")) {
					if (src.@lang.toString() == lang) {
						// Found the new language. Test if the source is different.
						if (_xml.@src.toString() != src.toString()) {
							_xml.@src = src.toString();
							return true;
						} else {
							// Found but no change.
							return false;
						}
					} else if (src.@lang.toString() == defLang) {
						defFallback = src.toString();
					}
				}
			}
			// Fallback to default language.
			if (defFallback != "" && _xml.@src.toString() != defFallback) {
				_xml.@src = defFallback;
				return true;
			}
			return false;
		}
		
		/**
		 * Onload the element. If the element is loading the loading progress
		 * is cancelled. If the element is not loaded nothing happens.
		 */
		internal function unload():void {
			if (_element != null) {
				// Remove from stage and null self.
				if (_element.parent != null) {
					if (_element.mask) {
						_element.parent.removeChild(_element.mask)
					}
					_element.parent.removeChild(_element);
				}
				_element = null;
			} else if (_loader) {
				// Cancel loading.
				_loader.close();
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				_loader = null;
			}
		}
		
	}
	
}
