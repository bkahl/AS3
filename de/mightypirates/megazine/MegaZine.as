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
	
	import com.adobe.utils.ArrayUtil;
	import de.mightypirates.megazine.events.*;
	import de.mightypirates.megazine.gui.*;
	import de.mightypirates.utils.*;
	import flash.system.Capabilities;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	
	/**
	 * Represents a book with all it's pages and settings and stuff. Can be controlled using
	 * the public methods to navigate to different pages.
	 * Some methods, such as getThumbnailsFor, getAbsPath are mainly meant to be used by element
	 * classes or other internal classes, but may prove to be of use for external use as well.
	 * 
	 * Possible events to be listened to:
	 * MegaZineEvent.MESSAGE - fired when a message is logged.
	 * MegaZineEvent.SLIDE_START - Fired when slideshow starts.
	 * MegaZineEvent.SLIDE_STOP - Fired when slideshow stops.
	 * MegaZineEvent.PAGE_CHANGE - Fired when the current page changes.
	 * MegaZineEvent.PAGE_COMPLETE - Fired when a page finished loading. Only fired if all pages
	 * can possibly be present in memory at a time. Then holds the number of pages loaded so far.
	 * MegaZineEvent.MUTE - When sounds should be muted.
	 * MegaZineEvent.UNMUTE - When sounds should be unmuted.
	 * MegaZineEvent.STATUS_CHANGE - Fired when the current status (loading, ready...) changes.
	 * 
	 * Loaded pages are stored in two base containers, one for the odd, one for the even
	 * pages. Depending on the current turning direction one overlaps the other. Individual
	 * page visibility is handled as well - this is done by checking twice, once for odd,
	 * once for even pages, starting from the current ones. If a page is transparent we
	 * continue to check for the next page and so on. All other pages are made invisible.
	 * 
	 * Basic hierarchy goes as such:
	 *                                 o
	 *                                 |
	 *                            +----------+       +---------------+   +----------+
	 *               +------------| MegaZine |-------|  DragHandler  |---| DragPath |
	 *          +----+----+       +----------+       +---------------+   +----------+
	 *          | Chapter |            |            /       |
	 *          +----+----+       +----------+-----+ +---------------+
	 *               +------------|   Page   |-------|  PageLoader   |
	 *                            +----------+       +---------------+
	 *                                 |                    |
	 *                            +----------+       +---------------+
	 *                            | Element  |-------| ElementLoader |
	 *                            +----------+       +---------------+
	 *                                 |
	 *                        +-----------------+
	 *                        | AbstractElement |
	 *                        +-----------------+
	 *                         |       |       |
	 *                    +-------+ +------+
	 *                    | Image | | Area |  . . .
	 *                    +-------+ +------+
	 * 
	 * With all the stuff in de.mightypirates.megazin.gui.* attached somewhat to MegaZine,
	 * and the Localizer (and Logger) being somewhat attached to pretty much everything.
	 * 
	 * @author fnuecke
	 */
	public class MegaZine extends Sprite implements IMegaZine {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** MegaZine Release Version (displayed in console) */
		private static const VERSION:String             = "1.29";
		
		
		/**
		 * All pages were loaded. This state can only be achieved when all pages may be loaded
		 * into memory at the same time.
		 */
		public  static const COMPLETE:String            = "completed";
		
		/** Fatal error occured while loading, meaning the megazine was not loaded completely. */
		public  static const ERROR:String               = "error";
		
		/** Currently loading the xml data containing setup information and page data. */
		public  static const LOADING:String             = "loading";
		
		/** Not yet started loading. */
		public  static const PREINIT:String             = "preinit";
		
		/**
		 * The XML was loaded and parsed. So was the GUI. The MegaZine is now ready for turning
		 * pages and all user interaction. If enabled GUI is shown.
		 * Page content may or may not be loaded. As it might be impossible to tell when all
		 * pages are loaded (e.g. when only loading a given number of pages in range of the
		 * current one, which is the preferred loading model) there is no "complete" state.
		 */
		public  static const READY:String               = "ready";
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables (internally generated)
		// ----------------------------------------------------------------------------------- //
		
		/** Absolute path to the swf file containing the megazine */
		private var _absolutePath:String;
		
		/** The background fade (the gradient behind the book) */
		private var _backgroundFader:Shape;
		
		/** Blocker sprite used to block clicks in the area where page turns and drags work */
		private var _blocker:Sprite;
		
		/**
		 * Boolean array telling which buttons to show in the gui.
		 * IMPORTANT: Even = left to page buttons, odd = right
		 */
		/*
		Entries in the _buttonShow array
		0 = Fullscreen
		1 = Last
		2 = Slideshow Play/Pause
		3 = Mute/Unmute
		4 = First
		5 = Settings
		*/
		private var _buttonShow:Array; // Boolean
		
		/**
		 * Current main page (always an even number, i.e. the number of the right
		 * visible page
		 */
		private var _currentPage:uint = 0;
		
		/**
		 * Handles page dragging. Has its own event listeners to react to user mouse input.
		 * As this object only supports "gotoPage" the anchors and next/first/last/prev page
		 * methods reside in the megazine object and call the gotoPage method in the dragHandler
		 * in turn.
		 */
		private var _dragHandler:DragHandler;
		
		/** Known image galleries */
		private var _galleries:Dictionary; // Array // Array
		
		/** The help window */
		private var _help:Help;
		
		/**
		 * Language strings used throughout the megazine for the interface. Loaded manually from
		 * an extra xml file if needed. Else fills with default values (in english).
		 */
		private var _localizer:Localizer;
		
		/** The graphics library, used to get elements for the interface */
		private var _library:Library;
		
		/** The muted state of the megazine */
		private var _muted:Boolean = false;
		
		/**
		 * The navigation display object (page navigation, including fullscreen and mute buttons
		 * as well as the actual pagination to jump to a certain page).
		 */
		private var _navigation:Navigation;
		
		/**
		 * Page anchor mapping (page name to number), filled while parsing the page xml, this
		 * will contain a list of strings (the anchor names) pointing to uints (the page
		 * numbers). Anchors to chapters are stored here, too, pointing to the first page of
		 * the chapter.
		 */
		private var _pageAnchors:Dictionary; // String -> uint
		
		/**
		 * The page loader. Created once the xml is parsed. It is then responsible for loading
		 * all pages that should be currently stored in memory. There are two models: load all
		 * and load partial. In the first case all pages are loaded and kept in memory, in the
		 * second only a given number remains loaded at a time, pages out of range will be
		 * discarded to save memory.
		 */
		private var _pageLoader:PageLoader;
		
		/**
		 * The array holding all page objects, index is the page number. Because a page object
		 * consists of an odd an an even page (front and back) two following entries are always
		 * the same, i.e 0 and 1 point to the same Page object, 2 and 3 point to the same one
		 * and so on.
		 */
		private var _pages:Array; // Page
		
		/**
		 * Holds all even pages, needed for fast depth changes when the page turn direction
		 * changes. Like this only the containers of the even and odd pages have to be swapped.
		 */
		private var _pagesEven:DisplayObjectContainer;
		
		/**
		 * Number of pages already loaded. This is only used if it is possible for all pages
		 * to be loaded at once (maxLoaded >= totalPages). It is used to know when to set the
		 * state to COMPLETE.
		 */
		private var _pagesLoaded:uint = 0;
		
		/**
		 * Holds all odd pages, needed for fast depth changes when the page turn direction
		 * changes. Like this only the containers of the even and odd pages have to be swapped.
		 */
		private var _pagesOdd:DisplayObjectContainer;
		
		/**
		 * Total number of pages in the megazine. Cannot use _pages.length, because of how the
		 * pages are created (two pages are used to build one page object).
		 */
		private var _pagesTotal:uint = 0;
		
		/** The password form for entering the password if one is specified. */
		private var _passwordForm:PasswordForm;
		
		/**
		 * Image data for the reflection, updated only when visible, draws the whole area of the
		 * two pages, i.e. everything from the top left corner to the bottom right corner of the
		 * book.
		 */
		private var _reflectionData:BitmapData;
		
		/** Page reflections, the actual bitmap used for display. */
		private var _reflectionImage:Bitmap;
		
		/** The settings dialog */
		private var _settings:SettingsDialog;
		
		/**
		 * Slideshow timer, when running turns pages automatically. Timing can differ from page
		 * to page (specified in xml).
		 */
		private var _slideTimer:Timer;
		
		/** The current state of this instance, see constants */
		private var _state:String = PREINIT;
		
		/** Path to the interface swf (containing navigation, loading bar...) */
		private var _uiPath:String;
		
		/** The xml data holding all info on this instance */
		private var _xmlData:XML;
		
		/** Path to the xml file containing the data for this megazine */
		private var _xmlPath:String;
		
		/** The container for the zoom view */
		private var _zoomContainer:ZoomContainer;
		
		/** Was in fullscreen before opening zoom mode? */
		private var _zoomPrevFullscreen:Boolean;
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables (settings, changeable via xml)
		// ----------------------------------------------------------------------------------- //
		
		/** The vertical position of the navigation bar */
		private var _barPosition:String; // empty
		
		/** Use hand cursor instead of arrows */
		private var _handCursor:Boolean; // false
		
		/** Hide navigation */
		private var _hideNavigation:Boolean; // false
		
		/** Hide pagenumbers left and right to navigation */
		private var _hidePagenumbers:Boolean; // false
		
		/** Hide pagebuttons (the pagination) */
		private var _hidePagebuttons:Boolean; // false
		
		/** Ignore the system language when determining the default language */
		private var _ignoreSystemLanguage:Boolean; // false
		
		/** How many pages to load in parallel */
		private var _loadParallel:uint; // 4
		
		/** How many pages may be kept in memory */
		private var _maxLoaded:uint; // 22
		
		/** Show help initially */
		private var _openhelp:Boolean; // false
		
		/** The height of the MegaZine's pages */
		private var _pageHeight:uint; // 400
		
		/** Use page shadows (when turning) */
		private var _pageUseShadows:Boolean; // true
		
		/** The width of the MegaZine's pages (one page) */
		private var _pageWidth:uint; // 275
		
		/** Password for the MegaZine */
		private var _password:String; // ""
		
		/** Automatically generate thumbnails for books with a max amount of pages in memory */
		private var _thumbAuto:Boolean; // false
		
		/** Use the reflection effect */
		private var _useReflection:Boolean; // false
		
		/** Automatically go to fullscreen mode when clicking a zoom button */
		private var _zoomFullscreen:Boolean; // true
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Constructor, creates a new MegaZine instance.
		 * @param _xmlPath The path to the xml file to be used for building the MegaZine.
		 * @param _uiPath Path to the .swf that contains ui elements.
		 * @param delayLoad Do not start loading when added to stage if set to true.
		 */
		public function MegaZine(xmlPath:String = "megazine.xml",
								 uiPath:String  = "interface.swf",
								 delayLoad:Boolean = false) {
			
			// Initialize some variables
			//_self = this;
			_xmlPath = xmlPath;
			_uiPath  = uiPath;
			// Back to defaults if nothing was given.
			_xmlPath ||= "megazine.xml";
			_uiPath  ||= "interface.swf";
			
			_galleries   = new Dictionary();
			_pages       = new Array();
			_pageAnchors = new Dictionary();
			_buttonShow  = new Array(true,  // Fullscreen
									 true,  // Last page
									 true,  // Mute
									 true,  // Slideshow
									 true,  // Help
									 true,  // Settings
									 true,  // First page
									 true); // Language chooser
			
			// Create page containers, hide initially.
			_pagesEven = new Sprite();
			_pagesOdd  = new Sprite();
			_pagesEven.visible = false;
			_pagesOdd.visible  = false;
			addChild(_pagesEven);
			addChild(_pagesOdd);
			
			// Create the draghandler
			_dragHandler = new DragHandler(this);
			// Forward page change events and update currentpage.
			_dragHandler.addEventListener(MegaZineEvent.PAGE_CHANGE, onPageChange);
			
			// Slide Timer setup
			_slideTimer = new Timer(5000);
			_slideTimer.addEventListener(TimerEvent.TIMER, onSlideTimer);
			
			// Begin loading if allowed and stage is known, else wait for
			// stage / manual triggering.
			if (!delayLoad) {
				if (stage) {
					load();
				} else {
					// Wait until added to stage before initializing mouse
					// event listeners and refreshes.
					addEventListener(Event.ADDED_TO_STAGE, load);
				}
			}
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The mute state for all elements that support it.
		 */
		public function get muted():Boolean {
			return _muted;
		}
		
		/**
		 * Sets mute state for all elements that support it by firing a MegaZineEvent.MUTE event.
		 */
		public function set muted(mute:Boolean):void {
			_muted = mute;
			// Then fire an event for all elements that are registered to it
			if (mute) {
				dispatchEvent(new MegaZineEvent(MegaZineEvent.MUTE));
			} else {
				dispatchEvent(new MegaZineEvent(MegaZineEvent.UNMUTE));
			}
			var so:SharedObject = SharedObject.getLocal("megazine3");
			so.data.isMuted = mute;
		}
		
		/**
		 * Get the number of pages in the book.
		 * @return The number of pages in the book.
		 */
		public function get pageCount():uint {
			return _pagesTotal;
		}
		
		/**
		 * Get the default height for pages
		 * @return The defaut height for pages
		 */
		public function get pageHeight():uint {
			return _pageHeight;
		}
		
		/**
		 * Get the default width for pages
		 * @return The defaut width for pages
		 */
		public function get pageWidth():uint {
			return _pageWidth;
		}
		
		/**
		 * Get the current setting for reflection useage
		 * @return The current setting for reflection useage
		 */
		public function get reflection():Boolean {
			return _useReflection;
		}
		
		/**
		 * Set the reflection useage
		 * @param enabled Enable the reflection or disable it.
		 */
		public function set reflection(enabled:Boolean):void {
			_useReflection = enabled;
		}
		
		/**
		 * Get the state of shadow useage for pages
		 * @return The state of shadow useage for pages
		 */
		public function get shadows():Boolean {
			return _pageUseShadows;
		}
		
		/**
		 * Set the state of shadow useage for pages
		 * @param enabled The new state of shadow useage for pages
		 */
		public function set shadows(enabled:Boolean):void {
			_pageUseShadows = enabled;
		}
		
		/**
		 * Get the current state of this instance
		 * @return The current state of this instance
		 */
		public function get state():String {
			return _state;
		}
		
		/**
		 * Set the current state of this instance, triggers notification.
		 * @param state The new state for this instance
		 */
		private function setState(_state:String):void {
			var e:MegaZineEvent = new MegaZineEvent(MegaZineEvent.STATUS_CHANGE,
													0, _state, this._state)
			this._state = _state;
			dispatchEvent(e);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		// ----------------------------------------------------------------------------------- //
		// Getter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Converts relative paths to absolute paths, using the location of the swf
		 * holding the megazine as the base location all paths are relative to.
		 * If the url starts with one of the allowed protocol types assume the url
		 * is already absolute and return it as it was, else add the absolute path
		 * component and return it.
		 * @param url The original path/url.
		 * @param protocols Array of allowed protocols that will be recognized. Per default
		 * the following protocols are recognized: http, https, file. Protocols must be defined
		 * with the completely, i.e. up to the point where the actual address starts.
		 * E.g. http is defined as http://
		 * @return The absolute path to the location specified in the given url.
		 */
		public function getAbsPath(url:String, protocols:Array = null):String {
			if (!protocols) protocols = ["http://", "https://", "file://"];
			for each (var prot:String in protocols) {
				if (url.search(prot) == 0) {
					return url;
				}
			}
			return _absolutePath + url;
		}
		
		/**
		 * Lists some basic information about all pages in the book.
		 * @return A string with information on the pages, separated by newlines.
		 */
		public function getPageInfos():String {
			// Conversion helper (dec to hex) for colors
			function dec2hex(dec:int):String {
				function d2h(d:int):String {
					var c:Array = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
								   'A', 'B', 'C', 'D', 'E', 'F'];
					return c[int(d / 16)] + c[d % 16];
				}
				return "0x" + d2h((dec >>> 24) & 255)
							+ d2h((dec >>> 16) & 255)
							+ d2h((dec >>> 8) & 255)
							+ d2h(dec & 255);
			}
			
			var ret:String = "";
			for (var i:int = 0; i < _pages.length; i += 2) {
				ret += "Page " + i + "/" + (i + 1) + ": visible="
					+ (_pages[i] as Page).pageEven.visible + "/"
					+ (_pages[i] as Page).pageOdd.visible
					+ "; state=" + (_pages[i] as Page).state
					+ "; bgcolor=" + dec2hex((_pages[i] as Page).getBackgroundColor(true)) + "/"
					+ dec2hex((_pages[i] as Page).getBackgroundColor(false))
					+ "; slidedelay=" + (_pages[i] as Page).getSlideDelay()
					+ "; loadstate=" + (_pages[i] as Page).getLoadState(true) + "/"
					+ (_pages[i] as Page).getLoadState(false) + "\n";
			}
			return ret;
		}
		
		/**
		 * Gets the thumbnails for the left and right page for the given page.
		 * @param page The page number for which to get the left and right page.
		 * @return An array with the left page at 0 and the right at 1.
		 */
		public function getThumbnailsFor(page:int):Array {
			// Make it an even page number
			page += page & 1;
			// Request prioritized generation
			_pageLoader.prioritizeThumbForPage(page - 1);
			// Return bitmaps...
			return [_pages[page - 1] != null
						? (_pages[page - 1] as Page).getPageThumbnail(false)
						: null,
					_pages[page] != null ? (_pages[page] as Page).getPageThumbnail(true) : null];
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Loading
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Begin loading the megazine. Only has an effect while the megazine is in the PREINIT
		 * state. Starts loading the xml file with the megazine configuration and parses it plus
		 * generates all pages defined. Then loads the gui and sounds.
		 * After that the state is changed to READY. At the same time the actual content for the
		 * pages is loaded.
		 * If not specified otherwise in the constructor, this method is automatically called as
		 * soon as the megazine object is added to the stage.
		 * @param e make method able to be called on stage added events.
		 */
		public function load(e:Event = null):void {
			if (!stage) {
				throw new Error("Must be added to stage first.");
			}
			
			if (state == PREINIT) {
				
				
				Logger.log("MegaZine", "MegaZine Version " + VERSION + " initialized.",
						   Logger.TYPE_SYSTEM_NOTICE);
				
				
				// Only fire once
				removeEventListener(Event.ADDED_TO_STAGE, load);
				
				// Keyboard event listeners (arrow navigation)
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
				
				// Redrawing
				addEventListener(Event.ENTER_FRAME, redraw);
				
				// Get absolute path
				// Replace backslashes with slashes for ie in windows -.-
				_absolutePath = loaderInfo.loaderURL.replace(/\\/g, "/");
				_absolutePath = _absolutePath.slice(0, _absolutePath.lastIndexOf("/")) + "/";
				_xmlPath = getAbsPath(_xmlPath);
				_uiPath = getAbsPath(_uiPath);
				
				// Create graphics library (unloaded for now)
				_library = new Library(_uiPath);
				
				// Begin loading the xml data
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, onXMLLoaded);
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, onXMLError);
				
				
				Logger.log("MegaZine", "Begin loading XML data from file '"
						   + Helper.trimString(_xmlPath, 40) + "'.");
				
				
				setState(LOADING);
				
				try {
					// Add a random parameter to force reloading the xml.
					xmlLoader.load(new URLRequest(_xmlPath
									+ "?r=" + Math.round(Math.random() * 1000000)));
				} catch (ex:Error) {
					Logger.log("MegaZine", "Could not load XML data: " + ex.toString(),
							   Logger.TYPE_ERROR);
					createErrorMessage("<b>Error</b><br/>Could not load XML data: "
									   + ex.toString());
					setState(ERROR);
				}
			} else {
				Logger.log("MegaZine", "MegaZine already loaded or loading.");
			}
			
		}
		
		/**
		 * Load the gui.
		 * @param noGui Do not show the pagination or page numbers.
		 */
		private function loadGUI():void {
			
			Logger.log("MegaZine", "Begin loading interface graphics from '"
								   + Helper.trimString(_uiPath, 30) + "'.");
			
			_library.addEventListener(MegaZineEvent.LIBRARY_COMPLETE, onLibraryComplete);
			_library.addEventListener(MegaZineEvent.LIBRARY_ERROR, onLibraryError);
			_library.load();
			
		}
		
		/**
		 * Error loading xml data.
		 * @param	e
		 */
		private function onXMLError(e:IOErrorEvent):void {
			Logger.log("MegaZine", "Could not load XML data: " + e.text, Logger.TYPE_ERROR);
			createErrorMessage("<b>Error</b><br/>Could not load XML data: " + e.text);
			setState(ERROR);
		}
		
		/**
		 * Called when the loading of the xml data is complete.
		 * @param e The event data
		 */
		private function onXMLLoaded(e:Event):void {
			
			
			Logger.log("MegaZine", "XML loaded successfully.");
			
			
			// Initialize the xml object with the loaded data.
			XML.ignoreComments   = true;
			XML.ignoreWhitespace = true;
			XML.ignoreProcessingInstructions = false;
			
			try {
				_xmlData = new XML(e.target.data);
			} catch (ex:Error) {
				Logger.log("MegaZine", "Invalid XML data! " + ex.toString(), Logger.TYPE_ERROR);
				createErrorMessage("<b>Error</b><br/>Invalid XML data! " + ex.toString());
				setState(ERROR);
				return;
			}
			
			
			// And begin parsing it
			Logger.log("MegaZine", "Begin parsing XML data.");
			
			
			// Settings
			
			Logger.log("MegaZine", "  Parsing settings...");
			
			// Get shared object with locally stored user settings
			var so:SharedObject = SharedObject.getLocal("megazine3");
			
			// Width of a page. Can be any positive number.
			// !!! READ FIRST AS IT IS NEEDED FOR SOME OTHER VARS FOR DEFAULT CALCULATION. !!!
			_pageWidth = Helper.validateUInt(_xmlData.@pagewidth, 275);
			
			// Height of a page. Can be any positive number
			// !!! READ FIRST AS IT IS NEEDED FOR SOME OTHER VARS FOR DEFAULT CALCULATION. !!!
			_pageHeight = Helper.validateUInt(_xmlData.@pageheight, 400);
			
			// Background color.
			var pageBackgroundColor:uint = Helper.validateUInt(_xmlData.@bgcolor, 0xFFCCCCCC);
			
			// Distance to keep from originating border while dragging.
			// Can be any value between 1 and pagewidth.
			var dragKeepDistance:uint = Helper.validateUInt(_xmlData.@dragkeepdist,
															_pageWidth >> 4, 1, _pageWidth);
			
			// Distance in which to start autodragging / make borders clickable.
			// Can be any value between 1 and pagewidth
			var dragRange:uint = Helper.validateUInt(_xmlData.@dragrange, _pageWidth >> 2,
													 1, _pageWidth);
			
			// Page move speed. Can be any value between 0 and 1.
			var dragSpeed:Number = Helper.validateNumber(_xmlData.@dragspeed, 0.25, 0.001, 1);
			
			// Folding effects alpha value. Must be a number between 0 and 1.
			var pageFoldEffectAlpha:Number = Helper.validateNumber(_xmlData.@foldfx, 0.5, 0, 1);
			
			// Number of pages that can be turned before instantly jumping to the target.
			// Can be any positive number (incl. 0, which means only instant jumps)
			var instantJumpCount:uint = Helper.validateUInt(_xmlData.@instantjumpcount, 5);
			
			// Number of pages that can be turned before going to low quality.
			// Can be any positive number (incl. 0, which means quality is reduced always
			var pagesToLowQuality:uint = Helper.validateUInt(_xmlData.@lowqualitycount, 2);
			
			// Use hand cursor instead of images from interface.
			_handCursor = Helper.validateBoolean(_xmlData.@handcursor, false);
			
			// Number of pages to load at once. Can be any positive number greater 0.
			_loadParallel = Helper.validateUInt(_xmlData.@loadparallel, 4, 1);
			
			// Number of pages that are to be kept in memory. Can be any positive
			// number greater 1.
			_maxLoaded = Helper.validateUInt(_xmlData.@maxloaded, 22);
			
			// Vertical position of the navigation bar.
			_barPosition = Helper.validateString(_xmlData.@barpos, "");
			
			// Disable gui?
			_hideNavigation = !Helper.validateBoolean(_xmlData.@navigation, true);
			
			// Show page numbers of current pages next to pagination.
			_hidePagenumbers = !Helper.validateBoolean(_xmlData.@pagenumbers, true);
			
			// Show page buttons (the pagination).
			_hidePagebuttons = !Helper.validateBoolean(_xmlData.@pagebuttons, true);
			
			// Ignore the system language when determining the default language.
			_ignoreSystemLanguage = Helper.validateBoolean(_xmlData.@ignoresyslang, false);
			
			// Password for entering. Can be anything. If empty, no pw is needed.
			_password = Helper.validateString(_xmlData.@password, "");
			
			// Use page sounds (dragging, restoring, turning) or not.
			var usePageTurnSounds:Boolean = Helper.validateBoolean(_xmlData.@pagesounds, true);
			
			// Use page reflections per default or or not.
			if (so.data.useReflection != undefined) {
				_useReflection = so.data.useReflection;
			} else {
				_useReflection = Helper.validateBoolean(_xmlData.@reflection, false);
			}
			
			// Use page shadows and highlights per default when turning or not.
			var shadowIntensity:Number = Helper.validateNumber(_xmlData.@shadows, 0.25);
			_pageUseShadows = shadowIntensity > 0;
			// If disabled initially negative values give the actual intensity.
			if (!_pageUseShadows) shadowIntensity *= -1;
			if (so.data.useShadows != undefined) {
				_pageUseShadows = so.data.useShadows;
			}
			
			// Time in ms to show a page before turning to the next one in seconds.
			// Must be at least one second.
			var slideDelay:uint = Helper.validateUInt(_xmlData.@slidedelay, 5, 1);
			_slideTimer.delay = slideDelay * 1000;
			
			// Automatically load thumbnaisl
			_thumbAuto = Helper.validateBoolean(_xmlData.@thumbauto, false);
			
			// Show help initially?
			_openhelp = Helper.validateBoolean(_xmlData.@openhelp, false);
			
			// Automatically go to fullscreen when clicking a zoom button
			_zoomFullscreen = Helper.validateBoolean(_xmlData.@zoomfs, true);
			
			// Specially parsed settings.
			
			// Error level for logging.
			if (_xmlData.@errorlevel != undefined) {
				// Reset to no reporting
				var _errorReporting:uint = Logger.TYPE_NONE;
				
				// Multiple reporting levels can be given via the binary or (|),
				// so we split the string there...
				var allErr:Array = _xmlData.@errorlevel.toString().split("|");
				
				// And then go through each single message type...
				for each (var errid:String in allErr) {
					switch (errid.replace(/ /g, "")) {
						// And concatenate them with a binary or (|)
						case "ALL":
							_errorReporting = _errorReporting | Logger.TYPE_ALL;
							break;
						case "ERROR":
							_errorReporting = _errorReporting | Logger.TYPE_ERROR;
							break;
						case "WARNING":
							_errorReporting = _errorReporting | Logger.TYPE_WARNING;
							break;
						case "NOTICE":
							_errorReporting = _errorReporting | Logger.TYPE_NOTICE;
							break;
						default:
							Logger.log("MegaZine", "    Unknown error reporting level named '" + 
								   errid.replace(/ /g, "") + "'.", Logger.TYPE_WARNING);
							break;
					}
				}
				
			} else {
				_errorReporting = Logger.TYPE_WARNING | Logger.TYPE_ERROR;
			}
			if ((_errorReporting & Logger.TYPE_NOTICE) == 0) {
				Logger.log("MegaZine", "    Disabling notices.", Logger.TYPE_SYSTEM_NOTICE);
			}
			Logger.level = _errorReporting;
			
			// Definition of which gui buttons to show.
			var buttonsRaw:String = Helper.validateString(_xmlData.@hidebuttons, "");
			if (buttonsRaw != "") {
				// Parse the string.
				var buttons:Array = buttonsRaw.split(" ");
				for each (var bname:String in buttons) {
					switch (bname) {
						case "fullscreen":
							_buttonShow[0] = false;
							break;
						case "last":
							_buttonShow[1] = false;
							break;
						case "mute":
							_buttonShow[2] = false;
							break;
						case "slideshow":
							_buttonShow[3] = false;
							break;
						case "help":
							_buttonShow[4] = false;
							break;
						case "settings":
							_buttonShow[5] = false;
							break;
						case "first":
							_buttonShow[6] = false;
							break;
						case "language":
							_buttonShow[7] = false;
							break;
					}
				}
				// Hide fullscreen button regardless if player does not support fullscreen
				if (stage["displayState"] == undefined) {
					_buttonShow[4] = false;
				}
			}
			
			// Restore mute state
			muted = so.data.isMuted;
			
			// Pass the read settings on to the drag handler
			_dragHandler.setXMLVars(_handCursor, usePageTurnSounds, dragKeepDistance,
								   dragRange, dragSpeed, pagesToLowQuality, instantJumpCount);
			
			// Use localized strings if given
			var langs:String = Helper.validateString(_xmlData.@lang, "en");
			// Avoid empty string - fall back to english
			langs ||= "en";
			
			var langAr:Array = langs.split(",");
			langAr.forEach(
				function(item:*, index:int, array:Array):void {
					// Remove spaces
					array[index] = (item as String).replace(/ /g, "");
				});
			
			// Create the localizer.
			_localizer = new Localizer(langAr[0].toLowerCase());
			
			// Then load all languages.
			for each (var langID:String in langAr) {
				// Build url
				var langPath:String = getAbsPath("lang." + langID.toLowerCase() + ".xml");
				
				Logger.log("MegaZine", "Begin loading localized strings from file '"
									   + Helper.trimString(langPath, 40) + "'.");
				
				// Begin loading the xml data
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, onLocalizationComplete);
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						Logger.log("MegaZine", "Could not load XML data for localization: "
											   + e.text, Logger.TYPE_WARNING);
					});
				try {
					// Add a random parameter to force reloading the xml.
					xmlLoader.load(new URLRequest(langPath
									+ "?r=" + Math.round(Math.random() * 1000000)));
				} catch (ex:Error) {
					Logger.log("MegaZine", "Could not load XML data for localization: "
										   + ex.toString(), Logger.TYPE_WARNING);
				}
			}
			
			// If it's only one language do not show button in navigation
			_buttonShow[7] = langAr.length > 1;
			
			// Settings end.
			Logger.log("MegaZine", "  Done parsing settings.");
			
			
			// Do the basic setup, now that we have the settings.
			Logger.log("MegaZine", "  Initializing variables and graphics...");
			
			
			// Factor the frame rate into the drag speed (constant speeds regardless of fps)
			if (stage) dragSpeed *= 25 / stage.frameRate;
			
			// Page diagonale minus _pageHeight (which is the maximum distance a corner can be
			// dragged over the edge, vertically). Needed in the next two steps.
			var pageOverflow:Number = Math.round(Math.sqrt(_pageWidth * _pageWidth +
												_pageHeight * _pageHeight) - _pageHeight);
			
			// Click blocker in border area.
			_blocker = new Sprite();
			_blocker.graphics.beginFill(0xFFFFFF, 0);
			_blocker.graphics.drawRect(0, 0, dragRange, _pageHeight);
			_blocker.graphics.drawRect(_pageWidth * 2 - dragRange, 0, dragRange, _pageHeight);
			_blocker.graphics.endFill();
			addChild(_blocker);
			
			// Draw the background fader
			var faderMatrix:Matrix = new Matrix();
			faderMatrix.createGradientBox(_pageWidth * 2 + 200, _pageHeight * 0.3,
										  Math.PI * 0.5, -100, _pageHeight * 0.9);
			_backgroundFader = new Shape();
			_backgroundFader.graphics.beginGradientFill(GradientType.LINEAR,
														[0xFFFFFF, 0xFFFFFF],
												  		[0.1, 0], [0, 255], faderMatrix);
			_backgroundFader.graphics.drawRect(-100, _pageHeight * 0.9,
											   _pageWidth * 2 + 200, _pageHeight * 0.3);
			_backgroundFader.graphics.endFill();
			
			// Mask for the background fader
			var backgroundFaderMask:Shape = new Shape();
			var faderMaskMatrix:Matrix = new Matrix();
			faderMaskMatrix.createGradientBox(_pageWidth * 2 + 200, _pageHeight * 0.3,
											  0, -100, _pageHeight * 0.9);
			backgroundFaderMask.graphics.beginGradientFill(GradientType.LINEAR,
														[0xFF00FF, 0xFF00FF, 0xFF00FF, 0xFF00FF],
														[0, 1, 1, 0],
														[0, 40, 215, 255], faderMaskMatrix);
			backgroundFaderMask.graphics.drawRect(-100, _pageHeight * 0.9,
												  _pageWidth * 2 + 200, _pageHeight * 0.3);
			backgroundFaderMask.graphics.endFill();
			
			addChildAt(_backgroundFader, 0);
			addChild(backgroundFaderMask);
			
			_backgroundFader.cacheAsBitmap = true;
			backgroundFaderMask.cacheAsBitmap = true;
			_backgroundFader.mask = backgroundFaderMask;
			
			// Reflection bitmapdata and bitmap
			_reflectionData = new BitmapData(_pageWidth * 2, _pageHeight, true, 0);
			_reflectionImage = new Bitmap(_reflectionData);
			
			// Position the reflection and add it to the container.
			_reflectionImage.y = _pageHeight;
			_reflectionImage.alpha = 0.4;
			addChildAt(_reflectionImage, 0);
			
			// Initialization end.
			Logger.log("MegaZine", "  Done initializing...");
			
			// Reserved anchor names
			var reservedAnchors:Array = new Array("first", "last", "prev", "next");
			var tmpAnchor:String;
			
			// Load an image left to the cover (page -1).
			var prePageURL:String = Helper.validateString(_xmlData.@prepage, "");
			if (prePageURL != "") {
				// Try to load it right now...
				var prepage:Loader = new Loader();
				prePageURL = getAbsPath(prePageURL);
				prepage.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						Logger.log("MegaZine", "Could not load prepage: " + e.text,
								   Logger.TYPE_WARNING);
					});
				try {
					prepage.load(new URLRequest(prePageURL));
				} catch (ex:Error) {
					Logger.log("MegaZine", "Could not load prepage: " + ex.toString(),
					           Logger.TYPE_WARNING);
				}
				var prepageMask:Shape = new Shape();
				prepageMask.graphics.beginFill(0xFF00FF);
				prepageMask.graphics.drawRect(0, 0, _pageWidth, _pageHeight);
				prepageMask.graphics.endFill();
				prepage.mask = prepageMask;
				_pagesOdd.addChildAt(prepageMask, 0);
				_pagesOdd.addChildAt(prepage, 0);
			}
			
			// Pages
			if (_xmlData.elements("chapter").length() < 1) {
				_pageHeight = 0;
				_pageWidth = 0;
				Logger.log("MegaZine", "No chapters defined.", Logger.TYPE_ERROR);
				createErrorMessage("<b>Error</b><br/>No chapters defined.");
				setState(ERROR);
				return;
			} else {
				
				Logger.log("MegaZine", "  Parsing chapters and pages...");
				
				// Chapter array... used to loop through in the very end (after the
				// dummy page is inserted, if necessary; the one if an odd number of
				// pages is given).
				var chapters:Array = new Array();
				
				// Current chapter. Outside for possibly forced last page.
				var chapter:Chapter;
				
				// Initialize page data variables.
				var pageData:Array = new Array(new XML(), new XML());
				var pageContent:Array = new Array(new Sprite(), new Sprite());
				var pageShadow:Array = new Array(new Sprite(), new Sprite());
				
				// Slideshow delay of the previous page
				var prevDelay:uint = 0;
				
				// Loop through all chapters.
				for each (var chapterXML:XML in _xmlData.elements("chapter")) {
					
					// Create the chapter object.
					chapter = new Chapter(this, chapterXML, chapters.length,
										  pageBackgroundColor, pageFoldEffectAlpha,
										  slideDelay);
					
					// Check if the chapter should be batch filled.
					var pageBatch:Array = Helper.validateString(chapterXML.@pages, "").split("|");
					if (pageBatch[0]) {
						if (pageBatch.length < 2) {
							pageBatch.push("");
						}
						// See if there is a numeric range given.
						var loopMatch:Function = function(raw:String, repl:Array, list:Array):void {
							repl = ArrayUtil.copyArray(repl);
							var range:Array = repl.shift().replace("[", "").replace("]", "").split("-");
							if (range.length == 0) {
								return;
							} else if (range.length == 1) {
								range.unshift(1);
							}
							for (var i:int = int(range[0]); i <= int(range[1]); i++) {
								if (repl.length == 0) {
									list.push([raw.replace(/\[\d+(\-\d+)?(|.+)?\]/, i),
											   raw.replace(/\[\d+(\-\d+)?(|.+)?\]/, i+pageBatch[1])]);
								} else {
									loopMatch(raw.replace(/\[\d+(\-\d+)?(|.+)?\]/, i), repl, list);
								}
							}
						}
						var urls:Array = new Array();
						loopMatch(pageBatch[0], pageBatch[0].match(/\[\d+(\-\d+)?(|.+)?\]/g), urls);
						// Create the pages.
						var gallery:String = "__generated" 
											+ (Math.random() * 1000000).toString()
											+ (new Date().getTime()).toString();
						for each (var imgURL:Array in urls) {
							chapterXML.appendChild("<page><img src=\"" + imgURL[0]
													+ "\" width=\"" + _pageWidth
													+ "\" height=\"" + _pageHeight
													+ (pageBatch[1]
														? "\"hires=\"" + imgURL[1]
														  + "\" iconpos=\"center"
														  + "\" gallery=\"" + gallery
														: "")
													+ "\"/></page>");
						}
					}
					
					// Check if there are any pages in the chapter, if not skip it.
					if (chapterXML.elements("page").length() > 0) {
						
						chapters.push(chapter);
						
						// If the chapter has an anchor specified, store it.
						tmpAnchor = Helper.validateString(chapterXML.@anchor, null);
						if (tmpAnchor) {
							if (reservedAnchors.indexOf(tmpAnchor) >= 0
								|| int(tmpAnchor) > 0
								|| tmpAnchor == "0")
							{
								Logger.log("MegaZine",
										   "Invalid anchor name (reserved name or numeric): "
										   + tmpAnchor, Logger.TYPE_WARNING);
							} else {
								_pageAnchors[chapterXML.@anchor.toString()] = _pagesTotal;
							}
						}
						
						for (var i:int = 0; i < chapterXML.elements("page").length(); i++) {
							// Odd or even id...
							var id:int = _pagesTotal & 1;
							
							// Get XML data for the page.
							pageData[id] = chapterXML.elements("page")[i];
							
							// Building the gallery... check for img elements.
							for each (var element:XML in pageData[id].elements("img")) {
								var hiresPath:String = Helper.validateString(element.@hires, "");
								var galleryName:String =
													Helper.validateString(element.@gallery, "");
								if (hiresPath != "" && galleryName != "") {
									hiresPath = getAbsPath(hiresPath);
									registerGalleryImage(galleryName, _pagesTotal, hiresPath);
								}
							}
							
							// If the page has an anchor specified, store it.
							tmpAnchor = Helper.validateString(pageData[id].@anchor, null);
							if (tmpAnchor) {
								if (reservedAnchors.indexOf(tmpAnchor) >= 0
									|| int(tmpAnchor) > 0
									|| tmpAnchor == "0")
								{
									Logger.log("MegaZine",
											   "Invalid anchor name (reserved name or numeric): "
											   + tmpAnchor, Logger.TYPE_WARNING);
								} else {
									_pageAnchors[pageData[id].@anchor.toString()] = _pagesTotal;
								}
							}
							
							// Mark page for registration.
							chapter.addPage(_pagesTotal);
							
							// Every odd page create the page object.
							if ((_pagesTotal & 1) == 1) {
								
								// Create the page object.
								_pages.push(new Page(this, _localizer, _library,
													chapter.getSlideDelay(),
													chapter.getPageBackgroundColor(),
													chapter.getPageFoldEffectAlpha(),
													_pagesTotal,pageData, pageContent,
													pageShadow, shadowIntensity, prevDelay,
													dragSpeed, dragKeepDistance));
								
								// Remember previous page's delay
								prevDelay =
										(_pages[_pages.length - 1] as Page).getSlideDelay(true);
								
								// Duplicate the entry.
								_pages.push(_pages[_pages.length - 1] as Page);
								
								// Add the objects to the stage and create the ones for the
								// next double page.
								_pagesEven.addChildAt(pageContent[0], 0);
								_pagesEven.addChildAt(pageShadow[0], 0);
								_pagesOdd.addChild(pageShadow[1]);
								_pagesOdd.addChild(pageContent[1]);
								
								pageData = new Array(new XML(), new XML());
								pageContent = new Array(new Sprite(), new Sprite());
								pageShadow = new Array(new Sprite(), new Sprite());
								
							}
							
							Logger.log("MegaZine", "    Chapter " + chapters.length
								   + ": Page " + _pagesTotal + "... done.");
							
							// Increase page counter.
							_pagesTotal++;
							
						}
						
					}
					
				}
				
				if (_pagesTotal == 0) {
					// No pages defined.
					_pageHeight = 0;
					_pageWidth = 0;
					Logger.log("MegaZine", "No pages defined.", Logger.TYPE_ERROR);
					createErrorMessage("<b>Error</b><br/>No pages defined.");
					setState(ERROR);
					return;
				} else if ((_pagesTotal & 1) == 1) {
					// If an odd number of pages was given fill in a blank one at the end.
					
					// Create the page object.
					_pages.push(new Page(this, _localizer, _library, chapter.getSlideDelay(),
										chapter.getPageBackgroundColor(),
										chapter.getPageFoldEffectAlpha(), _pagesTotal,
										pageData, pageContent, pageShadow,
										shadowIntensity, prevDelay,
										dragSpeed, dragKeepDistance));
					// Duplicate the entry.
					_pages.push(_pages[_pages.length - 1] as Page);
					
					// Register the page with the last chapter.
					chapter.addPage(_pagesTotal);
					
					// Add the objects to the stage and create the ones for the
					// next double page.
					_pagesEven.addChildAt(pageContent[0], 0);
					_pagesEven.addChildAt(pageShadow[0], 0);
					_pagesOdd.addChild(pageShadow[1]);
					_pagesOdd.addChild(pageContent[1]);
					
					Logger.log("MegaZine", "    Chapter " + chapters.length
						   + ": Page " + _pagesTotal
						   + " forcibly injected for even page count... done.");
					
					// Increase page counter.
					_pagesTotal++;
				}
			}
			
			// Initialize foldfx
			for (var pageNum:uint = 0; pageNum < _pages.length; pageNum++) {
				(_pages[pageNum] as Page).initFoldFX((pageNum & 1) == 0, _pagesTotal);
				if (_pagesTotal <= _maxLoaded) {
					(_pages[pageNum] as Page).addEventListener(MegaZineEvent.PAGE_COMPLETE,
															   onPageLoaded);
				}
			}
			
			// Loop through the chapters
			for each (chapter in chapters) {
				chapter.registerEvents(_pages);
			}
			
			// Startpage given? If yes try to go to it.
			_currentPage = Helper.validateInt(_xmlData.@startpage, 1, 1) - 1;
			
			// Load an image right to the back cover (pagesTotal + 1).
			var postPageURL:String = Helper.validateString(_xmlData.@postpage, "");
			if (postPageURL != "") {
				// Try to load it right now...
				var postpage:Loader = new Loader();
				postPageURL = getAbsPath(postPageURL);
				postpage.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						Logger.log("MegaZine", "Could not load postpage: " + e.text,
								   Logger.TYPE_WARNING);
					});
				try {
					postpage.load(new URLRequest(postPageURL));
				} catch (ex:Error) {
					Logger.log("MegaZine", "Could not load postpage: " + ex.toString(),
					           Logger.TYPE_WARNING);
				}
				var postpageMask:Shape = new Shape();
				postpageMask.graphics.beginFill(0xFF00FF);
				postpageMask.graphics.drawRect(_pageWidth, 0, _pageWidth, _pageHeight);
				postpageMask.graphics.endFill();
				postpage.mask = postpageMask;
				postpage.x = _pageWidth;
				_pagesEven.addChildAt(postpageMask, 0);
				_pagesEven.addChildAt(postpage, 0);
			}
			
			Logger.log("MegaZine", "  Done parsing and instantiating chapters and pages.");
			Logger.log("MegaZine", "Done parsing XML.");
			
			// Begin loading gui
			loadGUI();
			
		}
		
		/**
		 * Localization XML loaded completely. Parse it.
		 * @param e to get the loaded data.
		 */
		private function onLocalizationComplete(e:Event):void {
			try {
				var _xmlData:XML = new XML(e.target.data);
				var _xmlSubdata:XMLList = _xmlData.elements("langstring");
				if (_xmlSubdata.length() > 0) {
					var langID:String = Helper.validateString(_xmlData.@id, "").toLowerCase();
					if (langID == "") {
						Logger.log("MegaZine", "Invalid language file found "
											   + "(missing language id).", Logger.TYPE_WARNING);
					} else {
						Logger.log("MegaZine", "Parsing localized strings for language '"
											   + langID + "'...");
						for each (var node:XML in _xmlSubdata) {
							_localizer.registerString(langID, node.@name.toString(),
													  node.toString());
							Logger.log("MegaZine", "    " + node.@name.toString() + "="
										  + Helper.trimString(node.toString(), 30));
						}
						// "Officially" register the language
						_localizer.registerLanguage(langID);
						// Pick that language if it is the system language.
						if (langID == Capabilities.language && !_ignoreSystemLanguage) {
							_localizer.language = langID;
						}
						Logger.log("MegaZine", "Done parsing localized strings.");
					}
				} else {
					Logger.log("MegaZine", "No localized strings found.");
				}
			} catch (ex:Error) {
				Logger.log("MegaZine", "Loaded XML data for localization is invalid: "
									   + ex.toString(), Logger.TYPE_WARNING);
			}
		}
		
		/**
		 * Done loading the library, begin initializing the gui.
		 * @param e unused.
		 */
		private function onLibraryComplete(e:MegaZineEvent):void {
			
			// Get the cursor image references
			Cursor.init(_library, stage || this, _handCursor);
			
			// Setup custom navigation
			if (_library.custom) {
				// A custom gui was loaded. This means the navigation bar is the loaded gui
				// itself, and all scripting will be taken care of in it, so we do not need
				// to create a navigation bar.
				try {
					var nav:DisplayObject = _library.factory as DisplayObject;
					try {
						// Try with library...
						nav["setup"](this, _currentPage, _library);
					} catch (e:Error) {
						try {
							// Try without library.
							nav["setup"](this, _currentPage);
						} catch (e:Error) {
							// No setup function.
						}
					}
					nav.x = Math.round(_pageWidth - nav.width * 0.5);
					nav.y = _pageHeight;
					addChildAt(nav, 0);
				} catch (e:Error) {
					Logger.log("MegaZine", "Failed setting up custom navigation bar.",
							   Logger.TYPE_WARNING);
				}
			} else {
				// Setup the navigation by telling how many pages there are, the dimensions of the
				// thumbnails etc.
				try {
					// Above or below pages?
					var above:Boolean = false;
					var offset:int = 25;
					if (_barPosition != "") {
						var bposp:Array = _barPosition.split(" ");
						if (bposp.length > 0) {
							if (bposp.length == 2 && bposp[0] == "top") {
								above = true;
								offset = int(bposp[1]);
							} else {
								offset = int(bposp[0]);
							}
						}
					}
					
					// Create the navigation
					_navigation = new Navigation(_pagesTotal, pageWidth * 2 - 50, pageWidth / 5,
												 pageHeight / 5, _buttonShow, !_hidePagenumbers,
												 !_hidePagebuttons, !_hideNavigation, _currentPage,
												 above, offset, this, _localizer, _library);
					// Position and add it
					_navigation.x = 25;
					// Determine actual height (of the VISIBLE area)...
					var bmpd:BitmapData = new BitmapData(_pageWidth * 2, _pageHeight, true, 0);
					bmpd.draw(_navigation);
					var h:int = bmpd.getColorBoundsRect(0xFFFFFFFF, 0, false).height;
					// Then position
					var bpos:int;
					if (above) {
						bpos = - (h + offset);
					} else {
						bpos = _pageHeight + offset;
					}
					_navigation.y = bpos;
					// Add event listener
					_navigation.addEventListener(NavigationEvent.BUTTON_CLICK, onNavigationMenu);
					addChild(_navigation);
				} catch (e:Error) {
					Logger.log("MegaZine", "Error setting up navigation: " + e.toString(),
							   Logger.TYPE_WARNING);
				}
			}
			
			// Settings dialog
			if (_buttonShow[5]) {
				try {
					_settings = new SettingsDialog(this, _localizer, _library);
					_settings.x = _pageWidth - _settings.width * 0.5;
					_settings.y = _pageHeight - _settings.height - _pageHeight / 5 - 100;
					_settings.addEventListener("closed", onModalWindowClose);
					addChild(_settings);
				} catch (e:Error) {
					Logger.log("MegaZine", "Error setting up settings dialog: " + e.toString(),
							   Logger.TYPE_WARNING);
				}
			}
			
			// Setup the zoom frame
			try {
				// Create the zoom container
				_zoomContainer = new ZoomContainer(this, _pageWidth * 2, _pageHeight,
												    _localizer, _library);
				// Add listener for closing
				_zoomContainer.addEventListener(MegaZineEvent.ZOOM_CLOSED, onZoomClose);
				// Do not add to stage now because we use the add event to show the help the
				// first time the zoom opens.
				addChild(_zoomContainer);
			} catch (e:Error) {
				Logger.log("MegaZine", "Error setting up zoom frame: " + e.toString(),
						   Logger.TYPE_WARNING);
			}
			
			// Password check, if exists show pw form until right pw is entered.
			if (_password && _password.length > 0) {
				try {
					_passwordForm = new PasswordForm(_password, _localizer, _library);
					_passwordForm.addEventListener(MegaZineEvent.PASSWORD_CORRECT,
												   onPasswordCorrect);
					_passwordForm.x = int(_pageWidth - _passwordForm.width * 0.5);
					_passwordForm.y = int((_pageHeight - _passwordForm.height) * 0.5);
					addChild(_passwordForm);
					if (_navigation) {
						_navigation.visible = false;
					}
				} catch (e:Error) {
					Logger.log("MegaZine", "Failed setting up password form: " + e.toString(),
							   Logger.TYPE_WARNING);
					_pagesEven.visible = true;
					_pagesOdd.visible = true;
				}
			} else {
				// No password, show pages.
				_pagesEven.visible = true;
				_pagesOdd.visible = true;
			}
			
			// Help window
			_help = new Help(_localizer, _library, _buttonShow, !_hideNavigation);
			_help.x = pageWidth - _help.width * 0.5;
			_help.y = (pageHeight - _help.height) * 0.5;
			_help.addEventListener("closed", onModalWindowClose);
			addChild(_help);
			
			var so:SharedObject = SharedObject.getLocal("megazine3");
			if (_openhelp && !so.data.helpShown) {
				so.data.helpShown = true;
				_dragHandler.disabled = true;
			} else {
				_help.visible = false;
				onModalWindowClose();
			}
			
			Logger.log("MegaZine", "Done loading interface graphics.");
			
			// Begin loading the pages
			initPageLoad();
		}
		
		/**
		 * There was an error while loading the graphics for the interface...
		 * show the pages and initialize page load.
		 * @param e
		 */
		private function onLibraryError(e:MegaZineEvent):void {
			// Failed loading gui graphics, show pages and begin loading pages.
			_pagesOdd.visible = true;
			_pagesEven.visible = true;
			initPageLoad();
		}
		
		/**
		 * Precaller triggering the page loading...
		 */
		private function initPageLoad():void {
			
			// Log it...
			Logger.log("MegaZine", "Begin loading elements.");
			
			// Pages are initialized, register them
			_dragHandler.setPages(_pages, _pagesOdd, _pagesEven, _currentPage);
			
			// Begin loading as many pages parallely as allowed.
			_pageLoader = new PageLoader(this, _currentPage, _pages,
										 _loadParallel, _maxLoaded, _thumbAuto);
			
			// Set state to ready
			setState(READY);
			
		}
		
		/**
		 * Called when a page is finished loaded completely. Only used when all pages can be
		 * loaded at a time (in memory that is).
		 * @param e used to tell which page was loaded.
		 */
		private function onPageLoaded(event:MegaZineEvent):void {
			++_pagesLoaded;
			dispatchEvent(new MegaZineEvent(MegaZineEvent.PAGE_COMPLETE, _pagesLoaded));
			if (_pagesLoaded >= _pagesTotal) {
				setState(COMPLETE);
			}
		}
		
		/**
		 * Allow pages containing images with hires images belonging to
		 * a gallery to register those images.
		 * @param e The gallery event.
		 */
		private function registerGalleryImage(gallery:String, page:uint, path:String):uint {
			// Create array for gallery if it does not exist
			if (_galleries[gallery] == null) {
				_galleries[gallery] = new Dictionary();
			}
			// Create array for page if it does not exist
			if ((_galleries[gallery] as Dictionary)[page] == null) {
				(_galleries[gallery] as Dictionary)[page] = new Array();
			}
			var pos:int = ((_galleries[gallery] as Dictionary)[page] as Array).indexOf(path);
			if (pos < 0) {
				// Add entry to page array and return it's index
				return ((_galleries[gallery] as Dictionary)[page] as Array).push(path) - 1;
			} else {
				// Already known, return index
				return pos;
			}
		}
		
		/**
		 * Gets the position for the requested image in the gallery subarray.
		 * @param gallery The name of the gallery.
		 * @param page The number of the page.
		 * @param path The url of the hires image.
		 * @return The position in the page array in the gallery dictionary.
		 */
		internal function getGalleryData(gallery:String, page:uint, path:String):uint {
			return ((_galleries[gallery] as Dictionary)[page] as Array).indexOf(path);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Page navigation functions
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Go to the page with the specified anchor as specified in the xml. Chapter anchors are
		 * handled via this method as well, because their anchors are just mapped to their first
		 * page.
		 * If there is no such anchor it is checked whether it is a predefined anchor. Predefined
		 * anchors are: first, last, next, prev.
		 * If it is no predefined anchor it is checked whether a number was passed, and ich yes
		 * it is interpreted as a page number.
		 * If that fails too, nothing will happen.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param id The anchor id, predefined anchorname or page number.
		 * @param instant No animation, but instantly going to the page.
		 */
		public function gotoAnchor(id:String, instant:Boolean = false):void {
			if (_pageAnchors[id] != undefined) {
				gotoPage(_pageAnchors[id], instant);
			} else if (id == "first") {
				firstPage(instant);
			} else if (id == "last") {
				lastPage(instant);
			} else if (id == "next") {
				nextPage(instant);
			} else if (id == "prev") {
				prevPage(instant);
			} else if (int(id) > 0 || id == "0") {
				gotoPage(int(id), instant);
			} else {
				Logger.log("MegaZine", "No such anchor: '" + id + "'.");
			}
		}
		
		/**
		 * Go to the page with the specified number. Numeration begins with zero.
		 * If the number does not exist the method call is ignored.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param page The number of the page to go to.
		 * @param instant No animation, but instantly going to the page.
		 */
		public function gotoPage(page:uint, instant:Boolean = false):void {
			_dragHandler.gotoPage(page, instant);
		}
		
		/**
		 * Turn to the first page of the book.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param instant No animation, but instantly going to the page.
		 */
		public function firstPage(instant:Boolean = false):void {
			gotoPage(0, instant);
		}
		
		/**
		 * Turn to the last page of the book.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param instant No animation, but instantly going to the page.
		 */
		public function lastPage(instant:Boolean = false):void {
			gotoPage(_pagesTotal - 1, instant);
		}
		
		/**
		 * Turn to the next page in the book. If there is no next page nothing happens.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param instant No animation, but instantly going to the page.
		 */
		public function nextPage(instant:Boolean = false):void {
			gotoPage(_currentPage + 2, instant);
		}
		
		/**
		 * Turn to the previous page in the book. If there is no previous page nothing happens.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param instant No animation, but instantly going to the page.
		 */
		public function prevPage(instant:Boolean = false):void {
			gotoPage(_currentPage - 2, instant);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Other public functions
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Open the zoom mode for the image with the given path. The image is then loaded by
		 * the zoom container and displayed in full resolution. Pages and navigation / gui is
		 * hidden while the zoom is open.
		 * Alternatively a gallery name can be passed. In that case it is also necessary to
		 * pass a proper page number (of a page with images that are contained in that gallery)
		 * and the number of the image on that page.
		 * If set up accordingly this opens fullscreen mode. This only works if the call was
		 * initially triggered by a user action, such as a mouse click or key press.
		 * @param galleryOrPath The url to the image to load into the zoom frame, or the name
		 * of a gallery.
		 * @param page Only needed when a gallery name was passed. The number of the page the
		 * image object referencing to the gallery image resides in.
		 * @param number Only needed when a gallery name was passed. The number of the image
		 * in it's containing page (only images in the same gallery count).
		 */
		public function openZoom(galleryOrPath:String, page:int = -1, number:uint = 0):void {
			// Only if the zoom was loaded
			if (!_zoomContainer) {
				return;
			}
			// Stop slideshow when entering zoom
			slideStop();
			// Hide pages and navigation while in zoom mode.
			_pagesEven.visible = false;
			_pagesOdd.visible = false;
			if (_navigation) {
				_navigation.visible = false;
			}
			// Go to fullscreen?
			if (_zoomFullscreen) {
				try {
					if (stage["displayState"] != undefined) {
						_zoomPrevFullscreen =
											stage.displayState == StageDisplayState.FULL_SCREEN;
						if (!_zoomPrevFullscreen) {
							stage.displayState = StageDisplayState.FULL_SCREEN;
						}
					}
				} catch (e:Error) {}
			}
			// Open the zoom
			if (page < 0) {
				_zoomContainer.display(galleryOrPath);
			} else {
				_zoomContainer.setGalleryData(_galleries[galleryOrPath], page, number);
				_zoomContainer.display(_galleries[galleryOrPath][page][number]);
			}
		}
		
		/**
		 * Start the slideshow mode. If the current page has a delay of more than one second the
		 * first page turn is immediate (otherwise the user might get the impression nothing
		 * happened). Every next page turn will take place based on the delay stored for the
		 * current page.
		 * When the end of the book is reached the slideshow is automatically stopped.
		 * If slideshow is already active this method does nothing.
		 * Fires a MegaZineEvent.SLIDE_START event for this megazine object.
		 */
		public function slideStart():void {
			if (!_slideTimer.running) {
				// Update the delay
				if (_pages[_currentPage]) {
					_slideTimer.delay = (_pages[_currentPage] as Page).getSlideDelay() * 1000;
				}
				// Start timer
				_slideTimer.start();
				// Do first turn if wait time is long
				if (_slideTimer.delay > 1000) onSlideTimer();
				if (_slideTimer.running) {
					// Tell everyone interested
					dispatchEvent(new MegaZineEvent(MegaZineEvent.SLIDE_START));
				}
			}
		}
		
		/**
		 * Stop slideshow. If the slideshow is already stopped this method does nothing.
		 * Fires a MegaZineEvent.SLIDE_STOP event for this megazine object.
		 */
		public function slideStop():void {
			if (_slideTimer.running) {
				_slideTimer.stop();
				dispatchEvent(new MegaZineEvent(MegaZineEvent.SLIDE_STOP));
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Events
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * All keypresses go here, triggering possible page navigation.
		 * @param e Event data
		 */
		private function onKeyPressed(e:KeyboardEvent):void {
			
			// Only if the pages are already visible.
			if (!_pagesOdd.visible || !_pagesEven.visible) {
				return;
			}
			
			// Check what to do
			switch(e.keyCode) {
				case Keyboard.LEFT:
					prevPage();
					break;
				case Keyboard.RIGHT:
					nextPage();
					break;
				case Keyboard.HOME:
					firstPage();
					break;
				case Keyboard.END:
					lastPage();
					break;
			}
			
		}
		
		/** Modal window (help or settings) was closed, reenable drag handler */
		private function onModalWindowClose(e:Event = null):void {
			_dragHandler.disabled = false;
		}
		
		/**
		 * Handles menu button clicks in the navigation.
		 * @param e to determine what to do.
		 */
		private function onNavigationMenu(e:NavigationEvent):void {
			switch (e.subtype) {
				case NavigationEvent.FULLSCREEN:
					if (stage && stage["displayState"] != undefined) {
						try {
							stage.displayState = StageDisplayState.FULL_SCREEN;
						} catch (e:Error) {
							Logger.log("MegaZine", "Failed going into fullscreen mode: "
												   + e.toString(), Logger.TYPE_WARNING);
						}
					}
					break;
				case NavigationEvent.GOTO_PAGE:
					gotoPage(e.page);
					break;
				case NavigationEvent.HELP:
					if (_help) {
						if (_settings) {
							_settings.visible = false;
						}
						_help.visible = !_help.visible;
						_dragHandler.disabled = _help.visible;
					}
					break;
				case NavigationEvent.MUTE:
					muted = true;
					break;
				case NavigationEvent.PAGE_FIRST:
					firstPage();
					break;
				case NavigationEvent.PAGE_LAST:
					lastPage();
					break;
				case NavigationEvent.PAUSE:
					slideStop();
					break;
				case NavigationEvent.PLAY:
					slideStart();
					break;
				case NavigationEvent.RESTORE:
					if (stage && stage["displayState"] != undefined) {
						try {
							stage.displayState = StageDisplayState.NORMAL;
						} catch (e:Error) {
							Logger.log("MegaZine", "Failed leaving fullscreen mode: "
												   + e.toString(), Logger.TYPE_WARNING);
						}
					}
					break;
				case NavigationEvent.SETTINGS:
					if (_settings) {
						if (_help) {
							_help.visible = false;
						}
						_settings.visible = !_settings.visible;
						_dragHandler.disabled = _settings.visible;
					}
					break;
				case NavigationEvent.UNMUTE:
					muted = false;
					break;
			}
		}
		
		/**
		 * Triggered when the current page of the book changes. Redispatches the event.
		 * @param	e Used to get the new current page.
		 */
		private function onPageChange(e:MegaZineEvent):void {
			_currentPage = e.page;
			dispatchEvent(new MegaZineEvent(MegaZineEvent.PAGE_CHANGE, e.page));
		}
		
		/**
		 * Called when the correct password was entered in the passwordform.
		 * Make pages visible and remove the form.
		 */
		private function onPasswordCorrect(e:MegaZineEvent):void {
			  if (_navigation) {
				  _navigation.visible = true;
			  }
			  _pagesEven.visible = true;
			  _pagesOdd.visible = true;
			  removeChild(_passwordForm);
		}
		
		/**
		 * Slide show page turning triggered by timer.
		 * @param e The timer event object.
		 */
		private function onSlideTimer(e:TimerEvent = null):void {
			nextPage();
			// Update the delay
			if (_pages[_currentPage] && _currentPage < _pages.length) {
				_slideTimer.delay = (_pages[_currentPage] as Page).getSlideDelay() * 1000;
			} else {
				slideStop();
			}
		}
		
		/**
		 * Called when the zoom mode is closed. Restores other elements.
		 */
		private function onZoomClose(e:MegaZineEvent):void {
			if (e.page >= 0) {
				gotoPage(e.page, true);
			}
			// Show pages again...
			_pagesEven.visible = true;
			_pagesOdd.visible = true;
			// And navigation if it exists
			if (_navigation) {
				_navigation.visible = true;
			}
			// Return to normal?
			if (!_zoomPrevFullscreen) {
				try {
					stage.displayState = StageDisplayState.NORMAL;
				} catch (e:Error) {}
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Display updating
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Internal redraw function, redraws all pages. And the reflection if active.
		 */
		private function redraw(e:Event = null):void {
			
			// Tell all pages to redraw
			for (var i:int = 1; i < _pages.length; i += 2) {
				if ((_pages[i] as Page).pageEven.parent == _pagesEven ||
					(_pages[i] as Page).pageOdd.parent == _pagesOdd)
				{
					(_pages[i] as Page).redraw();
				}
			}
			
			// Update the reflection if they have been initialized.
			if (_reflectionImage != null
				&& _reflectionData != null
				&& _backgroundFader != null)
			{
				
				// Hide while rendering
				_reflectionImage.visible = false;
				
				if (_useReflection) {
					
					_backgroundFader.visible = false;
					var currvis:Array = [Cursor.visible,
										 _settings != null,
										 _help != null];
					
					Cursor.visible = false;
					if (currvis[1]) {
						currvis[1] = _settings.visible;
						_settings.visible = false;
					}
					if (currvis[2]) {
						currvis[2] = _help.visible;
						_help.visible = false;
					}
					
					_reflectionData.fillRect(_reflectionData.rect, 0);
					_reflectionData.draw(this, new Matrix(1, 0, 0, -1, 0, _pageHeight));
					
					// Make sure the reflection is visible
					_reflectionImage.visible = true;
					
					if (currvis[0]) {
						Cursor.visible = true;
					}
					if (currvis[1]) {
						_settings.visible = true;
					} else if (currvis[2]) {
						_help.visible = true;
					}
					
					_backgroundFader.visible = true;
				}
				
			}
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Miscellaneous
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Create a new fading message above of the pages.
		 * @param message The text message to display (language string ID)
		 * @param delay Time to wait before displaying. If a delay is given the dispatcher and
		 * event type are ignored.
		 * @param color Text color.
		 * @param dispatcher Dispatcher to observer.
		 * @param eventType Event type for which to wait before showing message.
		 * @return The resulting fading message object.
		 */
		private function createErrorMessage(message:String):void {
			var duration:int = (message != null && message != "")
								? Math.sqrt(message.length) * 0.75
								: -1;
			var fm:FadingMessage = new FadingMessage(message, this, this,
							  						 Event.ENTER_FRAME, true, 0xFF0000, 375);
			fm.y = -fm.height * 0.5;
		}
		
	}
	
}
