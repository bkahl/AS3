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
	
	import de.mightypirates.megazine.events.MegaZineEvent;
	import de.mightypirates.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	
	/**
	 * This class acts as an interface to SWF files which have the LibrarySWF class as their
	 * document class.
	 * It can be used to load graphics from these SWF files.
	 * 
	 * @author fnuecke
	 */
	public class Library extends EventDispatcher implements ILibrary {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Version number of the library */
		private static const VERSION:Number = 1.034;
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Custom library for specialized menu bar? */
		private var _custom:Boolean = false;
		
		/** The method used for obtaining new instances from the loaded library */
		private var _factory:ILibrarySWF;
		
		/** The loader used to load the swf */
		private var _loader:Loader;
		
		/** Path to the library to load */
		private var _path:String;
		
		/** Already the second try? */
		private var _secondTry:Boolean = false;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new library, based on the file at the given url.
		 * @param path Url to the swf used as a resource.
		 */
		public function Library(path:String) {
			_path = path;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Returns a new instance of the graphics object of the given type.
		 * @param id The type of the object. See constants.
		 * @return A new instance of the type, or null if invalid.
		 */
		public function getInstanceOf(id:String):DisplayObject {
			if (_factory) {
				return _factory.getInstanceOf(id) as DisplayObject;
			} else {
				return null;
			}
		}
		
		/**
		 * Tells if the loaded gui was meant for a custom navigation bar, realized via the swf
		 * itself.
		 */
		public function get custom():Boolean {
			return _custom;
		}
		
		/**
		 * The factory swf itself. Normally the getInstanceOf method should be used.
		 */
		public function get factory():ILibrarySWF {
			return _factory;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Start loading the library.
		 */
		public function load(path:String = ""):void {
			if (path) {
				_path = path;
			}
			
			try {
				_loader.load(new URLRequest(_path));
			} catch (e:SecurityError) {
				Logger.log("Library", "Could not load the library due to a security error.",
						   Logger.TYPE_WARNING);
				dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_ERROR));
			}
		}
		
		/**
		 * Completed loading the swf.
		 * @param e used to get the content of the swf.
		 */
		private function onComplete(e:Event):void {
			// Remove listeners
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			try {
				// Get the actual library movieclip
				_factory = e.target.loader.getChildAt(0) as ILibrarySWF;
				// Check version
				if (_factory.getVersion() < VERSION) {
					retry();
				} else {
					// Successfully loaded. Try calling the method.
					try {
						_factory.getInstanceOf("TEST");
					} catch (e:Error) {
						_factory = null;
						Logger.log("Library", "Loaded interface graphics library is invalid: "
											  + e.toString(), Logger.TYPE_WARNING);
						dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_ERROR));
						return;
					}
					
					// Custom library?
					if ((_factory as Object).hasOwnProperty("custom")) {
						_custom = Helper.validateBoolean(_factory["custom"], false);
					}
					
					// If we come here the loading process was successful
					dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_COMPLETE));
				}
			} catch (e:Error) {
				retry();
				return;
			}
			
		}
		
		/**
		 * Retry loading, this time avoid cache.
		 */
		private function retry():void {
			if (_secondTry) {
				// Outdated even after loading uncached version.
				Logger.log("Library", "Found version of interface graphics is outdated "
									  + "or invalid.", Logger.TYPE_WARNING);
				dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_ERROR));
			} else {
				// Outdated, try to avoid loading from cache.
				_factory = null;
				_secondTry = true;
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				try {
					_loader.load(new URLRequest(_path
								  + "?r=" + Math.round(Math.random() * 1000000)));
				} catch (e:SecurityError) {
					Logger.log("Library", "Could not load the interface graphics due to a "
										  + "security error.", Logger.TYPE_WARNING);
					dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_ERROR));
				}
			}
		}
		
		/**
		 * An error occured loading the swf.
		 * @param e used to generate the log message.
		 */
		private function onError(e:Event):void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			Logger.log("Library", "Error loading the interface graphics: " + e.toString(),
					   Logger.TYPE_WARNING);
			dispatchEvent(new MegaZineEvent(MegaZineEvent.LIBRARY_ERROR));
		}
		
	}
	
}