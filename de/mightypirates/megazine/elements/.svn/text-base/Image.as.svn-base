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
	import de.mightypirates.megazine.gui.*;
	import de.mightypirates.utils.*;
	import flash.geom.Point;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Matrix;
	import flash.net.*;
	import flash.utils.Timer;
	
	/**
	 * The Img element provides a loader for images and flash movies.
	 * 
	 * @author fnuecke
	 */
	public class Image extends AbstractElement {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The name of the gallery this image is in */
		private var _galleryName:String;
		
		/** Glow effect (faded in on mouseover if image is linked) */
		private var _glowFilter:GlowFilter;
		
		/**
		 * The loader object. Must be a class variable, otherwise there is a (small) chance
		 * that the garbage collector kills the loader before the image is loaded completely.
		 */
		private var _loader:Loader;
		
		/** The number of this image's zoom version in its gallery */
		private var _numInGallery:uint;
		
		/** Current target alpha for the glow */
		private var _targetGlowAlpha:Number = 0;
		
		/** The zoom button */
		private var _zoom:Sprite;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new image element.
		 * @param mz   The MegaZine containing the page containing this element.
		 * @param lib  The library to obtain gui graphics from.
		 * @param page The page containing this element.
		 * @param even On the odd or on the even page?
		 * @param xml  The XML data for this element.
		 */
		public function Image(mz:IMegaZine, loc:Localizer, lib:ILibrary,
							  page:IPage, even:Boolean, xml:XML)
		{
			super(mz, loc, lib, page, even, xml);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Loading
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Initialize loading. Done now so the creating object can add an event listener.
		 */
		override public function init():void {
			
			if (_xml.@src != undefined && _xml.@src.toString() != "") {
				var url:String = _mz.getAbsPath(_xml.@src.toString());
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoad);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						Logger.log("MegaZine Image",
								   "    Error loading file: " + Helper.trimString(url, 40)
								   + " in page " + (_page.getNumber(_even) + 1),
								   Logger.TYPE_WARNING);
						removeChild(_loading);
						dispatchEvent(new MegaZineEvent(MegaZineEvent.ELEMENT_COMPLETE,
														_page.getNumber(_even)));
					});
				if (Helper.validateBoolean(_xml.@nocache, false)) {
					url += "?r=" + Math.round(Math.random() * 1000000);
				}
				try {
					_loader.load(new URLRequest(url));
				} catch (e:Error) {
					Logger.log("MegaZine Image",
							   "    Error loading file '" + Helper.trimString(url, 40)
							   + "' via 'img' object in  page " + (_page.getNumber(_even) + 1),
							   Logger.TYPE_WARNING);
					removeChild(_loading);
					dispatchEvent(new MegaZineEvent(MegaZineEvent.ELEMENT_COMPLETE,
													_page.getNumber(_even)));
				}
			} else {
				Logger.log("MegaZine Image",
						   "    No source defined for 'img' object in page "
						   + (_page.getNumber(_even) + 1),
						   Logger.TYPE_WARNING);
				removeChild(_loading);
				dispatchEvent(new MegaZineEvent(MegaZineEvent.ELEMENT_COMPLETE,
												_page.getNumber(_even)));
			}
			
		}
		
		/**
		 * Called when the image or swf was successfully loaded.
		 * @param e The event object.
		 */
		private function onImageLoad(e:Event):void {
			// Width for this image (if smaller than 1 use sizes of loaded file)
			var sizex:Number = 0;
			// Height for this image (if smaller than 1 use sizes of loaded file)
			var sizey:Number = 0;
			// Container sprite for the image
			var cont:Sprite = new Sprite();
			// The image itself
			var img:DisplayObject;
			
			try {
				img = _loader.getChildAt(0);
				
				// Set scaling
				sizex = Helper.validateNumber(_xml.@width, _loader.width);
				sizey = Helper.validateNumber(_xml.@height, _loader.height);
				if (Math.abs(sizex) < 1) {
					sizex = Math.round(sizex * _loader.width);
				}
				if (Math.abs(sizey) < 1) {
					sizey = Math.round(sizey * _loader.height);
				}
				
				// Should the loaded be cached as a bitmap?
				var buffer:Boolean = Helper.validateBoolean(_xml.@static, false);
				if (img is AVM1Movie || img is MovieClip) {
					// Try setting it up.
					try {
						// Try everything.
						img["megazineSetup"](_mz, _page, _even, _library);
					} catch (e:Error) {
						try {
							// Only megazine and page data?
							img["megazineSetup"](_mz, _page, _even);
						} catch (e:Error) {
							try {
								// Most basic variant?
								img["megazineSetup"](_mz);
							} catch (e:Error) { }
						}
					}
					if (buffer) {
						// Own method to copy the image that does not update when not animating
						// or manipulating the display object
						var cacheData:BitmapData = new BitmapData(sizex, sizey, true, 0x00000000);
						// If possible set stage quality to best, for best results...
						if (_mz.stage) {
							var oldQuality:String = _mz.stage.quality;
							_mz.stage.quality = StageQuality.BEST;
							cacheData.draw(img, new Matrix(sizex / _loader.width, 0,
														   0, sizey / _loader.height),
										   null, null, null, true);
							_mz.stage.quality = oldQuality;
						} else {
							cacheData.draw(img, new Matrix(sizex / _loader.width, 0,
														   0, sizey / _loader.height),
										   null, null, null, true);
						}
						cacheData.lock();
						img = new Bitmap(cacheData);
					}
				} else {
					img.width = sizex;
					img.height = sizey;
				}
				
				// Should the image be antialiased?
				if ((img is Bitmap)) {
					(img as Bitmap).smoothing = Helper.validateBoolean(_xml.@aa, false);
				}
				
				// Move image from loader to self.
				cont.addChild(img);
				
				// If it is a linked image, add a overlay (borderglow) on mouseover
				// Images get a special treatment, because of the zoom functionality... so they
				// have to take care of linking themselves.
				var url:String = Helper.validateString(_xml.@url, "");
				
				var numLangs:uint = 0;
				// Generate unique id
				var uid:String = "element_img_title_" + (new Date().time).toString()
							   + int(Math.random() * 1000000).toString();
				// Check for title attribute. Handle it as an english entry.
				var title:String = Helper.validateString(_xml.@title, null);
				if (title != null && title != "") {
					_localizer.registerString(null, uid, title);
					numLangs++;
				}
				// Then check for child title elements.
				for each (var lang:XML in _xml.elements("title")) {
					var langID:String = Helper.validateString(lang.@lang, "");
					if (langID != "" && lang.toString() != "") {
						_localizer.registerString(langID, uid, lang.toString());
						numLangs++;
					}
				}
				// Create tooltip if we have a title.
				if (numLangs > 0) {
					// Create blank tooltip
					var tt:ToolTip = new ToolTip("", cont);
					_localizer.registerObject(tt, "text", uid);
				}
				
				// Create link from the element
				if (url != "") {
					url = _mz.getAbsPath(url, ["http://", "https://", "file://", "ftp://",
											   "mailto:", "anchor:"]);
					var target:String = Helper.validateString(_xml.@target, "_blank");
					// Check if a title was not defined, if so display the link address
					if (title == null && numLangs == 0) {
						new ToolTip(url, cont);
					}
					cont.buttonMode = true;
					cont.addEventListener(MouseEvent.CLICK,
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
									Logger.log("MegaZine Image",
											   "Error navigating to url '"
											   + Helper.trimString(url, 40)
											   + "': " + ex.toString(),
											   Logger.TYPE_WARNING);
								}
							}
						});
				}
				
				// Add container to stage
				addChild(cont);
				
				// High resolution version given?
				var hiresPath:String = Helper.validateString(_xml.@hires, "");
				if (hiresPath != "") {
					hiresPath = _mz.getAbsPath(hiresPath);
					if (url == "") {
						// No url, make whole image clickable.
						// Add event listener to trigger zoom.
						if (_galleryName) {
							cont.addEventListener(MouseEvent.CLICK,
								function(e:MouseEvent):void {
									_mz.openZoom(_galleryName, _page.getNumber(_even),
												 _numInGallery);
								});
						} else {
							cont.addEventListener(MouseEvent.CLICK,
								function(e:MouseEvent):void {
									_mz.openZoom(hiresPath);
								});
						}
						// Cursor change.
						cont.addEventListener(MouseEvent.MOUSE_OVER,
							function(e:MouseEvent):void {
								if (Cursor.cursor == Cursor.DEFAULT) {
									Cursor.cursor = Cursor.ZOOM;
								}
							});
						cont.addEventListener(MouseEvent.MOUSE_OUT,
							function(e:MouseEvent):void {
								if (Cursor.cursor == Cursor.ZOOM) {
									Cursor.cursor = Cursor.DEFAULT;
								}
							});
					}
					if (url != "" || Helper.validateBoolean(_xml.@showbutton, true)) {
						// Get new instance of a zoom button
						_zoom = _library.getInstanceOf(LibraryConstants.BUTTON_ZOOM) as Sprite;
						// Default position.
						_zoom.x = cont.width - _zoom.width;
						_zoom.y = cont.height - _zoom.height;
						// Then check for custom position.
						var iconpos:String = Helper.validateString(_xml.@iconpos, "");
						if (iconpos != "") {
							// Split the string into its components, ignoring superfluous spaces.
							var pos:Array = _xml.@iconpos.toString().split(" ").filter(
								function(value:*, index:int, array:Array):Boolean {
									return (value as String) != "";
								});
							if (pos.length > 0) {
								// x positioning
								var px:String = pos[0] as String;
								switch (px) {
									case "left":
										_zoom.x = 0;
										break;
									case "right":
										_zoom.x = cont.width - _zoom.width;
										break;
									case "center":
										_zoom.x = Math.floor((cont.width - _zoom.width) * 0.5);
										break;
									default:
										// Allow named positions to be for y if it's the only entry
										if (pos.length == 1) {
											if (px == "top") {
												_zoom.y = 0;
												break;
											} else if (px == "bottom") {
												_zoom.y = cont.height - _zoom.height;
												break;
											} else if (px == "middle") {
												_zoom.y =
													Math.floor((cont.height - _zoom.height) * 0.5);
												break;
											}
										}
										// Test for a number, if it is given assume it's the x 
										// coordinate
										if (int(px) >  0) {
											// Must not leave image area.
											_zoom.x = Math.min(int(px), cont.width - _zoom.width);
										}
										break;
								}
							}
							if (pos.length > 1) {
								// y positioning
								var py:String = pos[1] as String;
								switch (py) {
									case "top":
										_zoom.y = 0;
										break;
									case "bottom":
										_zoom.y = cont.height - _zoom.height;
										break;
									case "middle":
										_zoom.y = Math.floor((cont.height - _zoom.height) * 0.5);
										break;
									default:
										// Test for a number, if it is given assume it's the y
										// coordinate
										if (int(py) >  0) {
											// Must not leave image area.
											_zoom.y = Math.min(int(py), cont.height - _zoom.height);
										}
										break;
								}
							}
						}
						// Add event listener to trigger zoom.
						if (_galleryName) {
							_zoom["btn"].addEventListener(MouseEvent.CLICK,
								function(e:MouseEvent):void {
									_mz.openZoom(_galleryName, _page.getNumber(_even),
												 _numInGallery);
								});
						} else {
							_zoom["btn"].addEventListener(MouseEvent.CLICK,
								function(e:MouseEvent):void {
									_mz.openZoom(hiresPath);
								});
						}
						// Add tooltip.
						var ttz:ToolTip = new ToolTip("", _zoom);
						_localizer.registerObject(ttz, "text", "LNG_ZOOM_IN");
						// Add the zoom (depth)
						addChild(_zoom);
					}
				}
				
				// Use glow?
				if (Helper.validateBoolean(_xml.@useglow, true) && (url != "" || hiresPath != "")) {
					var size:int = int(Math.min(cont.width, cont.height) / 10);
					_glowFilter = new GlowFilter(0xFFFFFF, 0, size, size, 1,
												 BitmapFilterQuality.MEDIUM, true);
					var t:Timer = new Timer(25);
					t.addEventListener(TimerEvent.TIMER,
						function(e:TimerEvent):void {
							if (Math.abs(_glowFilter.alpha - _targetGlowAlpha) <= 0.1) {
								// Close enough, set it.
								t.stop();
								_glowFilter.alpha = _targetGlowAlpha;
								if (_targetGlowAlpha == 0) {
									img.filters = null;
									return;
								}
							} else {
								// Adjust the alpha.
								_glowFilter.alpha +=
										(_glowFilter.alpha < _targetGlowAlpha) ? 0.1 : -0.1;
							}
							img.filters = [_glowFilter];
						});
					cont.addEventListener(MouseEvent.MOUSE_OVER,
						function(e:MouseEvent):void {
							_targetGlowAlpha = 1;
							t.start();
						});
					cont.addEventListener(MouseEvent.MOUSE_OUT,
						function(e:MouseEvent):void {
							_targetGlowAlpha = 0;
							t.start();
						});
				}
				
			} catch (ex:Error) {
				Logger.log("MegaZine Image",
						   "Error loading image '" + Helper.trimString(hiresPath, 40)
						   + "': " + ex.toString(),
						   Logger.TYPE_WARNING);
			}
			
			_loader = null;
			
			super.init();
		}
		
		/**
		 * Sets the gallery data for this image.
		 * @param galleryName The name of the containing gallery.
		 * @param num The number.
		 */
		public function setGalleryData(galleryName:String, num:uint):void {
			_numInGallery = num;
			_galleryName = galleryName;
		}
		
	}
	
}
