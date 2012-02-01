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
	
	import de.mightypirates.megazine.elements.*;
	import de.mightypirates.megazine.events.*;
	import de.mightypirates.megazine.gui.Library;
	import de.mightypirates.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	
	/**
	 * Represents a page in the MegaZine.
	 * 
	 * Pages are made up from two single pages, to simulate a physical page.
	 * The default top page is always an even page.
	 * 
	 * Pages are no display objects by themselves but instead handle the display
	 * objects passed in the constructor method. This includes positioning and
	 * visibility.
	 * The passed objects therefore have to be handled appropriatetly and must
	 * have the same container objects or at least the same offset.
	 * 
	 * @author fnuecke
	 */
	internal class Page extends EventDispatcher implements IPage {
		
		// ----------------------------------------------------------------------------------- //
		// Constants (states)
		// ----------------------------------------------------------------------------------- //
		
		/** Page is currently being dragged */
		internal static const DRAGGING:String      = "dragging";
		
		/** A page is currently being dragged by the user (lmb is down) */
		internal static const DRAGGING_USER:String = "dragging_user";
		
		/** Page is waiting and ready for action */
		internal static const READY:String         = "ready";
		
		/** Page is currently going back where it came from */
		internal static const RESTORING:String     = "restoring";
		
		/** Page moves on to where its destined to go */
		internal static const TURNING:String       = "turning";
		
		
		/** Page is not loaded (contains no elements) */
		internal static const UNLOADED:String      = "unloaded";
		
		/** Page is loading */
		internal static const LOADING:String       = "loading";
		
		/** Page is loading, but only to generate a thumbnail (will be unloaded after laod) */
		internal static const LOADING_THUMB:String = "loading2";
		
		/** Page is loaded (all elements are loaded) */
		internal static const LOADED:String        = "loaded";
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The background color for this page */
		private var _backgroundColor:Array; // uint
		
		/** Where the corner currently is */
		private var _dragCurrent:Vector2D;
		
		/** The function describing the path the drag target moves along */
		private var _dragFunction:DragPath;
		
		/** Maximum distance the drag target may have from the bottom middle */
		private var _dragMaxDistBottom:Number;
		
		/** Maximum distance the drag target may have from the top middle */
		private var _dragMaxDistTop:Number;
		
		/**
		 * The offset of the page drag (always based on the top corner, this is the y offset of 
		 * the dragpoint)
		 */
		private var _dragOffset:Number = 0;
		
		/**
		 * Reference point while dragging for calculating the angles and stuff (basically the
		 * upper corner of the edge the drag started from)
		 */
		private var _dragReference:Vector2D;
		
		/** Bottom middle */
		private var _dragReferenceBottomMiddle:Vector2D;
		
		/** Top middle */
		private var _dragReferenceTopMiddle:Vector2D;
		
		/** Dragging speed for page position interpolation */
		private var _dragSpeed:Number;
		
		/** Where to drag the corner to */
		private var _dragTarget:Vector2D;
		
		/** The XMl data for the elements of the pages */
		private var _elements:Array // [even or odd][number], Element
		
		/** Number of elements that have been loaded */
		private var _elementsLoaded:Array; // [even or odd], Number
		
		/** The alpha value for the folding effects for this page */
		private var _foldEffectAlpha:Array;
		
		/** Distance to keep from originating border when dragging */
		private var _keepDistance:Number;
		
		/**
		 * The direction the pageturn goes - left to right or right to left.
		 * Also used to tell which way the pages currently lie when not moving.
		 */
		private var _leftToRight:Boolean = false;
		
		/** The main masks for the pages, for hiding them when turning */
		private var _maskMain:Array; // Shape
		
		/** The MegaZine this page belongs to */
		private var _mz:MegaZine;
		
		/** This will contain the page containers */
		private var _pageContainer:Array;
		
		/** The page diagonale */
		private var _pageDiagonale:Number = 0;
		
		/** The height of this page (height is also already taken) */
		private var _pageHeight:Number = 0;
		
		/** The number of this page (even one, so it will be 0, 2, 4 etc) */
		private var _pageNumber:uint = 0;
		
		/** Visibility state of the pages, used to check for changes in visibility for events */
		private var _pageVisibility:Array;
		
		/**
		 * The width of one page (width is already taken by the Sprite class this class extends)
		 */
		private var _pageWidth:Number = 0;
		
		/** Max alpha of _shadows */
		private var _shadowAlpha:Number;
		
		/** The masks for the shadows */
		private var _shadowMasks:Array;
		
		/**
		 * The shadow effects. 0|1 for the shadow being dropped on the background, 2|3 for the
		 * shadow on top of the page - each for the odd and even page (although only one each
		 * would be needed, we need 4 in total because of how depths are handled).
		 * 
		 * This is actually a bit of a misnomer. Initially I planned du use _shadows ON the pages
		 * as well, to fake volume. But now I use highlights on the pages, so...
		 */
		private var _shadows:Array;
		
		/** Slideshow delay for this page */
		private var _slideDelay:Array;
		
		/** Current state of the page */
		private var _state:String = READY;
		
		/** Current loading state of the page */
		private var _stateLoading:Array; // String
		
		/** Determines whether to render this as a stiff page or a normal one. */
		private var _stiff:Boolean = false;
		
		/** The _thumbnail images for this page */
		private var _thumbnail:Array; // Bitmap
		
		/** The _thumbnail image data for this page */
		private var _thumbnailData:Array; // BitmapData
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The page constructor.
		 * Loads the settings from either the defaults or the overriding XML attributes
		 * and fills the background appropriately. Also creates folding effects if needed.
		 * @param mz The MegaZine instance this page belongs to
		 * @param loc Localizer used for localizing displayed text.
		 * @param lib Graphics library used to get gui elements from.
		 * @param slideDelay Default display duration for this page in slideshow
		 * @param bgColor Default background color for this page.
		 * @param foldFX Default folding effect intensity for this page
		 * @param pageNumber The number of this page
		 * @param pageData An array with the xml data for the two pages
		 * @param pageContent The containers to be used for the pages (0 even, 1 odd)
		 * @param pageShadow The container to be used for the page shadows (0 even, 1 odd)
		 * @param shadowAlpha The maximum alpha value for shadows and highlights.
		 * @param prevDelay The slideshow delay of the odd part of the previous page
		 * @param dragSpeed The dragging speed, needed to determine how fast to animate turns
		 * @param dragKeepDist How far to stay away from the edge when dragging
		 */
		public function Page(mz:MegaZine, loc:Localizer, lib:Library, _slideDelay:uint,
							 bgColor:uint, foldFX:Number,
							 pageNumber:uint, pageData:Array,
							 pageContent:Array, pageShadow:Array,
							 shadowAlpha:Number, prevDelay:uint,
							 dragSpeed:Number, dragKeepDist:Number)
		{
			
			// Initialize objects and fill them with default values
			_dragTarget       = new Vector2D();
			_dragCurrent      = new Vector2D();
			_dragReference 	  = new Vector2D();
			
			_maskMain         = new Array(new Shape(), new Shape());
			_backgroundColor  = new Array(0, 0);
			_foldEffectAlpha  = new Array(0, 0);
			_pageContainer 	  = pageContent;
			_pageVisibility   = new Array(false, false);
			_shadowAlpha      = shadowAlpha;
			_dragSpeed        = dragSpeed;
			_keepDistance     = dragKeepDist;
			_stateLoading     = new Array(UNLOADED, UNLOADED);
			_elementsLoaded   = new Array(0, 0);
			
			// Remember the MegaZine this page belongs to
			_mz = mz;
			
			// Create the element wrappers
			_elements = new Array(new Array(), new Array());
			var elementXML:XML;
			var element:Element;
			for each (elementXML in (pageData[0] as XML).children()) {
				element = new Element(_mz, loc, lib, elementXML, this, true);
				element.addEventListener(MegaZineEvent.ELEMENT_COMPLETE, onElementLoaded);
				element.addEventListener(IOErrorEvent.IO_ERROR, onElementError);
				_elements[0].push(element);
			}
			for each (elementXML in (pageData[1] as XML).children()) {
				element = new Element(_mz, loc, lib, elementXML, this, false);
				element.addEventListener(MegaZineEvent.ELEMENT_COMPLETE, onElementLoaded);
				element.addEventListener(IOErrorEvent.IO_ERROR, onElementError);
				_elements[1].push(element);
			}
			
			// Add the containers as children for the display
			_mz.addChild(_maskMain[0]);
			_mz.addChild(_maskMain[1]);
			
			// And page number
			_pageNumber = pageNumber - 1;
			_pageWidth = _mz.pageWidth;
			_pageHeight = _mz.pageHeight;
			_pageDiagonale = Math.sqrt(_pageWidth * _pageWidth + _pageHeight * _pageHeight);
			_dragReferenceTopMiddle = new Vector2D(_pageWidth, 0);
			_dragReferenceBottomMiddle = new Vector2D(_pageWidth, _pageHeight);
			
			// Generate _thumbnail data objects
			_thumbnailData = [new BitmapData(_pageWidth / 5, _pageHeight / 5, true, 0),
							 new BitmapData(_pageWidth / 5, _pageHeight / 5, true, 0)];
			_thumbnail     = [new Bitmap(_thumbnailData[0]), new Bitmap(_thumbnailData[1])];
			
			// Stiff page or not? Must be checked beforehand, because it counts for both.
			_stiff = Helper.validateBoolean(pageData[1].@stiff,
											Helper.validateBoolean(pageData[0].@stiff, false));
			
			// Time in ms to show a page before turning to the next one in seconds.
			this._slideDelay = [Helper.validateUInt(pageData[0].@slidedelay,
								(prevDelay > 0 ? prevDelay : _slideDelay)),
							    Helper.validateUInt(pageData[1].@slidedelay, 0)];
			
			// Get data for the pages.
			for (var i:int = 0; i<2; i++) {
				
				// Get some per page settings stored in attributes
				// Background color overwriting the default one.
				_backgroundColor[i] = Helper.validateUInt(pageData[i].@bgcolor, bgColor);
				
				// Folding effects alpha value.
				_foldEffectAlpha[i] = Helper.validateNumber(pageData[i].@foldfx, foldFX, 0, 1);
				
				// Build the basic page layout
				
				// Check if alpha is zero but color is given, if so assume it's a 24 bit rgb
				// value, not a 32bit argb value.
				if (_backgroundColor[i] > 0 && (_backgroundColor[i] & 0xFF000000) == 0) {
					_backgroundColor[i] += 0xFF000000;
				}
				
				// Background fill (extracting the alpha channel)
				_pageContainer[i].graphics.beginFill(_backgroundColor[i] & 0xFFFFFF,
													(_backgroundColor[i] >>> 24) / 255);
				_pageContainer[i].graphics.drawRect(0, 0, _pageWidth, _pageHeight);
				_pageContainer[i].graphics.endFill();
				
				// Create the masks and elementcontainer
				_maskMain[i].graphics.beginFill(0xFF00FF);
				if (_stiff) {
					_maskMain[i].graphics.drawRect(0, _pageHeight - _pageDiagonale,
												  _pageWidth, _pageDiagonale);
				} else {
					_maskMain[i].graphics.drawRect(0, 0, _pageDiagonale * 2,
														_pageDiagonale * 3);
				}
				_maskMain[i].graphics.endFill();
				
				_pageContainer[i].mask = _maskMain[i];
				
			}
			
			// Shadows / Highlights
			
			// Initialize the array
			_shadows = new Array(4);
			
			// Masks
			_shadowMasks = new Array(4);
			
			// Matrix for masks
			var maskMatrix:Matrix = new Matrix();
			maskMatrix.createGradientBox(_pageWidth * 2, _pageHeight + _pageHeight * 0.1,
										 Math.PI * 0.5);
			
			// Matrix for the shadow
			var shadowMatrix:Matrix = new Matrix();
			shadowMatrix.createGradientBox(_pageWidth * 2, _pageHeight * 2, 0,
										   -_pageWidth, - _pageHeight);
			var shadowMatrix2:Matrix = new Matrix();
			shadowMatrix2.createGradientBox(_pageWidth, _pageHeight * 2, 0,
											-_pageWidth * 0.5, -_pageHeight);
			
			for (i = 0; i < (_stiff ? 2 : 4); i++) {
				
				_shadows[i] = i > 1 ? new Shape() : pageShadow[i == 0 ? 0 : 1];
				
				_shadowMasks[i] = new Shape();
				
				if (i < 2) {
					
					// The shadow
					_shadows[i].graphics.beginGradientFill(GradientType.LINEAR,
														  [0x000000, 0x000000, 0x000000],
														  [0, 1, 0],
														  [112, 128, 255],
														  shadowMatrix);
					_shadows[i].graphics.drawRect(-_pageDiagonale, -_pageDiagonale,
												 _pageDiagonale * 2, _pageDiagonale * 2);
					_shadows[i].graphics.endFill();
					
					// The mask
					_shadowMasks[i].graphics.beginFill(0xFF00FF);
					_shadowMasks[i].graphics.drawRect(0, 0, _pageWidth * 2, _pageHeight);
					_shadowMasks[i].graphics.endFill();
					
				} else {
					
					// The highlight
					_shadows[i].graphics.beginGradientFill(GradientType.LINEAR,
														  [0xFFFFFF, 0xFFFFFF, 0xFFFFFF],
														  [0, 1, 0],
														  [120, 160, 200],
														  shadowMatrix2);
					
					_shadows[i].graphics.drawRect(-_pageDiagonale * 0.5, -_pageDiagonale,
												 _pageDiagonale, _pageDiagonale * 2);
					_shadows[i].graphics.endFill();
					
					// The mask
					_shadowMasks[i].graphics.beginFill(0xFF00FF);
					_shadowMasks[i].graphics.drawRect(0, 0, _pageWidth, _pageHeight);
					_shadowMasks[i].graphics.endFill();
					
				}
				
				_shadows[i].mask = _shadowMasks[i];
				
				_shadows[i].visible = _mz.shadows;
				
			}
			
			_mz.addChild(_shadowMasks[0]);
			_mz.addChild(_shadowMasks[1]);
			
			// Move the masks of the _shadows to the right positions if this is a stiff page.
			if (_stiff) {
				_shadowMasks[0].x = _pageWidth;
				_shadowMasks[1].x = -_pageWidth;
			}
			
			// Starting position
			resetPage();
			
		}
		
		/**
		 * Initialize folding effects.
		 * @param even For the even page?
		 * @param total Number of total pages in the book, affects intensity.
		 */
		internal function initFoldFX(even:Boolean, total:uint):void {
			
			var i:uint = uint(!even);
			
			// Folding effects
			if (!_stiff && _foldEffectAlpha[i] > 0) {
				// The maximum and minimum percentual widths for the _shadows
				var maxWidth:Number = 0.16;
				var minWidth:Number = 0.02;
				// The max and min alpha values
				var maxAlpha:Number = Math.max(0.1, Math.min(0.9, total / 50.0));
				var minAlpha:Number = Math.max(0.1, maxAlpha / 4.0);
				// Decrease alpha based on how far we are away from the cover.
				// Otherwise the shadow would appear to be too intensive in the middle.
				var coverDistFactor:Number = 0.5 + Math.abs(Number(_pageNumber + i) / total - 0.5);
				maxAlpha *= coverDistFactor;
				minAlpha *= coverDistFactor;
				// Modify based on the settings.
				maxAlpha *= _foldEffectAlpha[i];
				minAlpha *= _foldEffectAlpha[i];
				
				// Calculate intensity for the current page
				var intensityRight:Number = Number(_pageNumber + i) / total;
				var intensityLeft:Number = 1.0 - intensityRight;
				
				// Prepare variables for the actual gradient fill.
				var foldEffectColors:Array = [0x000000, 0x000000];
				var foldEffectRatios:Array = [0, 255];
				var foldEffectMatrix:Matrix = new Matrix();
				var foldEffect:Shape = new Shape();
				var foldEffectAlphas:Array;
				
				// Which side to paint. The scaling done by actually scaling the whole
				// gradient, not by changing the ratios. This is because otherwise small
				// gradients look rather choppy.
				var width:Number;
				var alpha:Number;
				if (i == 1) {
					// Odd - left page
					alpha = minAlpha + (maxAlpha - minAlpha) * intensityLeft;
					foldEffectAlphas = [0, alpha];
					width = minWidth + (maxWidth - minWidth) * intensityRight;
					foldEffectMatrix.createGradientBox(_pageWidth * width, _pageHeight, 0,
													   _pageWidth - _pageWidth * width);
				} else {
					// Even - right page
					alpha = minAlpha + (maxAlpha - minAlpha) * intensityRight;
					foldEffectAlphas = [alpha, 0];
					width = minWidth + (maxWidth - minWidth) * intensityLeft;
					foldEffectMatrix.createGradientBox(_pageWidth * width, _pageHeight);
				}
				
				// Preform the gradient fill, drawing the folding effect.
				foldEffect.graphics.beginGradientFill(GradientType.LINEAR, 
														foldEffectColors, 
														foldEffectAlphas,
														foldEffectRatios,
														foldEffectMatrix);
				foldEffect.graphics.drawRect(0, 0, _pageWidth, _pageHeight);
				foldEffect.graphics.endFill();
				
				// Make it visible on the page
				_pageContainer[i].addChild(foldEffect);
				
			}
			
			// Add highlights
			if (!_stiff) {
				_pageContainer[0].addChild(_shadowMasks[2]);
				_pageContainer[0].addChild(_shadows[2]);
				_pageContainer[1].addChild(_shadowMasks[3]);
				_pageContainer[1].addChild(_shadows[3]);
			}
			
		}
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Tells whether the page is a stiff or a normal page.
		 */
		public function get isStiff():Boolean {
			return _stiff;
		}
		
		/**
		 * Get the even page part
		 * @return The even page display object
		 */
		public function get pageEven():DisplayObjectContainer {
			return _pageContainer[0];
		}
		
		/**
		 * Get the odd page part
		 * @return The odd page display object
		 */
		public function get pageOdd():DisplayObjectContainer {
			return _pageContainer[1];
		}
		
		/**
		 * Gets the page's state
		 * @return Current page state
		 */
		public function get state():String {
			return _state;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Sets the page's state, fires an event
		 * @param _state New page state
		 */
		private function setState(_state:String):void {
			// Create first to store the old page number.
			// Note on leftToRight: when turning the leftToRight is inverted before calling
			// resetPage(), thus it has to be "reinverted" here, to return the actual leftToRight
			// value from the page turn.
			var e:MegaZineEvent = new MegaZineEvent(MegaZineEvent.STATUS_CHANGE,
								  _pageNumber, _state, this._state,
								  state == TURNING ? !_leftToRight : _leftToRight)
			this._state = _state;
			dispatchEvent(e);
		}
		
		/**
		 * Get the loading state for one of the pages sides.
		 */
		internal function getLoadState(even:Boolean):String {
			return _stateLoading[int(!even)];
		}
		
		/**
		 * Get this page's background color
		 * @param even For the even page, or for the odd one
		 * @return This page's background color
		 */
		public function getBackgroundColor(even:Boolean):uint {
			return _backgroundColor[int(!even)];
		}
		
		/**
		 * Get the page's number. Not that this returns the logical page number, i.e. the
		 * count starts at 1. This is because this method is mainly used for display in
		 * the gui and so on.
		 * @return The page number
		 */
		public function getNumber(even:Boolean):uint {
			return _pageNumber + int(!even);
		}
		
		/**
		 * Get the BitMap object that is used for rendering the thumbnail.
		 * This BitMap is updated automatically.
		 * @return The BitMap with the thumbnail.
		 */
		public function getPageThumbnail(even:Boolean):Bitmap {
			return _thumbnail[int(!even)];
		}
		
		/**
		 * Get whether the even or odd page is visible or not.
		 * @param even Even or odd page.
		 * @return Visible or nor.
		 */
		public function getPageVisible(even:Boolean):Boolean {
			return _pageVisibility[int(!even)];
		}
		
		/**
		 * Gets the slide delay for this page, or this pages odd part.
		 * @param odd The page delay of the odd part. Returns negative if none.
		 * @return The slide delay of this page or its odd part.
		 */
		internal function getSlideDelay(odd:Boolean = false):int {
			return _slideDelay[int(odd)];
		}
		
		/**
		 * Sets the dragging target
		 * @param _dragTarget The new position to drag to
		 */
		internal function setDragTarget(target:Vector2D):void {
			
			_dragTarget.copy(target);
			
			// Check if dragging in corner inverts, if yes set to that corner.
			// Only works when dragging corners.
			if (_dragReference.y == 0 && _dragTarget.y < 0) {
				
				// Top corner
				if (_leftToRight && _dragTarget.x > _pageWidth * 2) {
					// Left to right and far enough to the right
					_dragTarget.setTo(_pageWidth * 2, 0);
				} else if (!_leftToRight && _dragTarget.x < 0) {
					// Right to left and far enough to the left
					_dragTarget.setTo(0, 0);
				}
				
			} else if (_dragReference.y == _pageHeight && _dragTarget.y > _pageHeight) {
				
				// Bottom corner
				if (_leftToRight && _dragTarget.x > _pageWidth * 2) {
					// Left to right and far enough to the right
					_dragTarget.setTo(_pageWidth * 2, _pageHeight);
				} else if (!_leftToRight && _dragTarget.x < 0) {
					// Right to left and far enough to the left
					_dragTarget.setTo(0, _pageHeight);
				}
				
			}
			
			validatePosition(_dragTarget);
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Loading
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Load a page's elements
		 * @param even The even or the odd page?
		 * @param total Number of total pages, used to calculate the intensities of the foldfx.
		 * @param thumb Only load the page to generate a thumbnail.
		 */
		internal function load(even:Boolean, loader:ElementLoader, thumb:Boolean = false):void {
			
			// For which page...
			var i:uint = uint(!even);
			var s:String = getLoadState(even);
			
			if (s != UNLOADED && (s != LOADING_THUMB || thumb)) {
				throw new Error("Already loading or loaded.");
			} else if (s == LOADING_THUMB && !thumb) {
				_stateLoading[i] = LOADING;
				return;
			}
			
			// Set loading state
			_stateLoading[i] = thumb ? LOADING_THUMB : LOADING;
			
			// Load the elements
			if ((_elements[i] as Array).length == 0) {
				
				Logger.log("MegaZine Page", "  No elements for page "
											+ (getNumber(even) + 1)  + ".");
				
				loadingComplete(even);
				
			} else {
				
				Logger.log("MegaZine Page", "  Begin loading elements for page "
											+ (getNumber(even) + 1) + ".");
				
				// Load all the elements. Inverse order, because we need to add at the bottom
				// to not overwrite folding effects and _shadows.
				_elementsLoaded[i] = 0;
				loader.addElements(_elements[i]);
			}
			
		}
		
		/**
		 * Onloads page elements, removing all elements form that page. The page has to be
		 * reloaded with the load method when it should be displayed again.
		 * @param even
		 */
		internal function unload(even:Boolean, loader:ElementLoader = null):void {
			
			// The id...
			var i:uint = uint(!even);
			
			// Check if the page is loaded. If it is not cancel.
			if (getLoadState(even) != LOADED) {
				// If loading mark it for unloading after load.
				if (getLoadState(even) == LOADING) {
					_stateLoading[i] = LOADING_THUMB;
				}
				return;
			}
			
			// Remove all children, thus making them ready for the garbage collector.
			for each (var e:Element in _elements[i]) {
				if (loader) loader.removeElement(e);
				e.unload();
			}
			
			// Set state
			_stateLoading[i] = UNLOADED;
			
		}
		
		/** Called when an element finishes loading. */
		private function onElementLoaded(e:MegaZineEvent):void {
			// Check which of the pages.
			var i:uint = (e.page & 1);
			
			// Create the mask (do not allow visible area to exceed that of the page)
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0xFF00FF);
			mask.graphics.drawRect(0, 0, _pageWidth, _pageHeight);
			mask.graphics.endFill();
			e.target.element.mask = mask;
			
			// Add at lowest level, so we do not override foldeffects and _shadows.
			var index:int = (_elements[i] as Array).indexOf(e.target);
			var cont:DisplayObjectContainer = _pageContainer[i];
			cont.addChildAt(e.target.element, 0);
			// Sort elements. Due to the loader elements might finish in another order than
			// they should display in, so fix that possibly jumbled order here.
			// Keep track of how many elements are missing so as not to step out of the valid range.
			var bias:uint = 0;
			// Parse all possible elements.
			for (var elementIndex:int = 0; elementIndex < _elements[i].length; elementIndex++) {
				// Get the actual element.
				var element:AbstractElement = _elements[i][elementIndex].element;
				// If it is loaded and on the display container swap it with the element at the
				// position it should be at.
				if (element != null && cont.contains(element)) {
					cont.swapChildrenAt(elementIndex - bias, cont.getChildIndex(element));
				} else {
					// Else we have a not loaded element; increase bias.
					bias++;
				}
			}
			// Add the mask for the element.
			cont.addChild(mask);
			
			increaseElementCounter(i == 0);
			
		}
		
		/** Failed loading an element */
		private function onElementError(e:IOErrorEvent):void {
			Logger.log("MegaZine Page", "    Page " + (_pageNumber + int(!e.target.even))
					   + ": " + e.text,
					   Logger.TYPE_WARNING);
			increaseElementCounter(e.target.even);
		}
		
		/**
		 * Increase the number of loaded elements for one of the pages, check if we're done.
		 * @param even Even or for the odd page.
		 */
		private function increaseElementCounter(even:Boolean):void {
			
			var i:uint = uint(!even);
			if (_elementsLoaded[i] >= (_elements[i] as Array).length) {
				// Already done, element was probably exchanged.
				return;
			} else if (++_elementsLoaded[i] >= (_elements[i] as Array).length) {
				// Done, fire event.
				loadingComplete(even);
			}
			
		}
		
		/**
		 * Done loading...
		 * @param even Even or odd page.
		 */
		private function loadingComplete(even:Boolean):void {
			
			var e:MegaZineEvent;
			if (getLoadState(even) == LOADING) {
				e = new MegaZineEvent(MegaZineEvent.PAGE_COMPLETE, getNumber(even),
									  LOADED, getLoadState(even))
				// Set state to loaded
				_stateLoading[int(!even)] = LOADED;
				// Generate thumbnail
				redraw(true);
			} else { // Only the thumb, afterwards unload again
				e = new MegaZineEvent(MegaZineEvent.PAGE_COMPLETE, getNumber(even),
									  UNLOADED, getLoadState(even))
				// Set state to loaded
				_stateLoading[int(!even)] = LOADED;
				// Generate thumbnail
				redraw(true);
				// Only the thumb
				unload(even);
			}
			// Dispatch event to let the world know we're done
			dispatchEvent(e);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Dragging
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Begin dragging this page to the specified position. The point on the edge of the
		 * page is defined by the offset and the direction (i.e. if the left or right edge
		 * is used).
		 * @param _dragTarget Where to drag the reference point on the edge to
		 * @param offset The y offset of the reference point on the edge
		 * @param leftToRight Turn the page left to right or right to left?
		 */
		internal function beginDrag(dragTarget:Vector2D,
									offset:Number,
									leftToRight:Boolean):void
		{
			
			// Check if the page is ready for dragging
			if (state == READY) {
				
				setState(DRAGGING);
				
				// Copy the basics
				this._leftToRight = leftToRight;
				
				if (_stiff) {
					// If it's a stiff page always set the offset to 0, because only the x
					// coordinate matters. Also we can skip the calculations of the max
					// distances.
					_dragOffset = 0;
				} else {
					// Copy the offset.
					_dragOffset = offset;
					// Allowed distances from the top and bottom middle points
					_dragMaxDistTop = Math.sqrt(_pageWidth * _pageWidth
												+ _dragOffset * _dragOffset);
					_dragMaxDistBottom = Math.sqrt(_pageWidth * _pageWidth +
								  (_pageHeight - _dragOffset) * (_pageHeight - _dragOffset));
					
				}
				
				// Check if we are dragging left to right or right to left and set the
				// starting point.
				_dragReference.setTo(leftToRight ? 0 : _pageWidth * 2, _dragOffset);
				
				// Set the current drag point to the starting location
				_dragCurrent.copy(_dragReference);
				
				setDragTarget(dragTarget);
				
				// Force the first update (to avoid flickers)
				redraw();
				
			} else {
				Logger.log("MegaZine Page", "The page (" + _pageNumber
											+ ") is not yet ready for dragging.");
			}
			
		}
		
		/**
		 * Begin dragging so that we won't restore, even if we get out of range of the corners.
		 * Triggered when the lmb is held down.
		 */
		internal function beginUserDrag():void {
			setState(DRAGGING_USER);
		}
		
		/**
		 * Cancel dragging and restore the page to its previous position
		 * @param instant Immediately reset the page
		 */
		internal function cancelDrag(instant:Boolean = false):void {
			
			if (state == DRAGGING || state == DRAGGING_USER) {
				
				setState(RESTORING);
				
				if (instant) {
					resetPage();
				} else {
					
					// Get the function describing the path to the starting point.
					// Make the arch steep, to get the page horizontal quickly.
					var height:Number = _dragCurrent.y - _dragOffset;
					var above:Boolean = false;
					var mult:Number = height;
					if (height < 0 ) {
						above = true;
						mult = -height;
					}
					
					mult /= _dragCurrent.distance(_dragReference) * 2;
					
					_dragFunction = new DragPath(_dragCurrent, _dragReference,
												(int(above) ^ int(_leftToRight)) ?
												DragPath.ARCH_RIGHT : DragPath.ARCH_LEFT,
												mult, _pageWidth * _dragSpeed * 0.25);
					
				}
				
			} else {
				
				Logger.log("MegaZine Page", "The page (" + _pageNumber
						   + ") is not being dragged, therefore the drag cannot be canceled.");
				
			}
			
		}
		
		/**
		 * Set position back to the default
		 */
		internal function resetPage():void {
			
			// Matrix used for resetting transformations set for the pages.
			var matrix:Matrix = new Matrix();
			
			// Reset positions to the defaults, remove rotations, skews.
			if (_leftToRight) {
				
				_pageContainer[1].transform.matrix = matrix;
				_maskMain[1].transform.matrix = matrix;
				if (_stiff) {
					matrix.tx = _pageWidth;
				}
				_maskMain[0].transform.matrix = matrix;
				matrix.tx = _pageWidth;
				_pageContainer[0].transform.matrix = matrix;
				
			} else {
				
				matrix.tx = _pageWidth;
				_pageContainer[0].transform.matrix = matrix;
				_maskMain[0].transform.matrix = matrix;
				matrix.tx = 0;
				_pageContainer[1].transform.matrix = matrix;
				_maskMain[1].transform.matrix = matrix;
				
			}
			
			setState(READY);
			
			updateShadowVisibility();
			
		}
		
		/**
		 * Finish the pagedrag and turn the page over. If not dragging, do a complete page turn.
		 */
		internal function turnPage(instant:Boolean = false, ltr:Boolean = false):void {
			
			var target:Vector2D;
			var archDir:String;
			
			if (instant) {
				_leftToRight = ltr;
				resetPage();
				return;
			} else if (state == DRAGGING || state == DRAGGING_USER) {
				
				// Page is being dragged, finish the drag
				var above:Boolean = _dragCurrent.y - _dragOffset < 0;
				archDir = (int(_leftToRight) ^ int(above)) == 0 ?
										DragPath.ARCH_LEFT :
										DragPath.ARCH_RIGHT;
				
			} else if (state == READY) {
				
				// At bottom, because we always arc up, and in that case dragging the top
				// would case overly fast movement in the first frames.
				_dragOffset = _pageHeight;
				_dragMaxDistTop = _pageDiagonale;
				_dragMaxDistBottom = _pageWidth;
				
				// Check if we are dragging left to right or right to left and set the starting
				// point.
				_dragReference.setTo(_leftToRight ? 0 : _pageWidth * 2, _dragOffset);
				
				// Set the current drag point to the starting location
				_dragCurrent.copy(_dragReference);
				
				// Not yet turning, do a complete page turn
				archDir = _leftToRight ? DragPath.ARCH_LEFT : DragPath.ARCH_RIGHT;
				
			} else {
				Logger.log("MegaZine Page", "The page (" + _pageNumber
											+ ") is not yet ready for turning.");
			}
			
			setState(TURNING);
			
			target = new Vector2D(_leftToRight ? _pageWidth * 2 : 0, _dragOffset);
			
			_dragFunction = new DragPath(_dragCurrent, target, archDir,
										0.05 + Math.random() * 0.05,
										_pageWidth * _dragSpeed * 0.5);
			
			// Force first update (to avoid flickers)
			_dragFunction.step();
			redraw();
			
		}
		
		/**
		 * Handles redrawing of the page (i.e. repositioning)
		 * @param forceThumbs Forces a thumbnail update, even if the thumbnails are not visible.
		 */
		internal function redraw(forceThumbs:Boolean = false):void {
			
			// Update thumbnails if they have a parent, i.e. if they are visible.
			for (var i:int = 0; i < 2; i++) {
				if ((forceThumbs || _thumbnail[i].parent != null)
					&& _stateLoading[i] == LOADED && _pageContainer[i].numChildren > 0)
				{
					// First remove the mask, so that nothing gets in the way.
					_pageContainer[i].mask = null;
					_shadows[0].visible = _shadows[1].visible = false;
					if (!_stiff) {
						_shadows[2].visible = _shadows[3].visible = false;
					}
					// First overpaint it with the page's background color (sans transparency)
					// or the default page color. 
					(_thumbnailData[i] as BitmapData).fillRect(
						new Rectangle(0, 0, _pageWidth / 5, _pageHeight / 5),
									  _backgroundColor[i]);
					// Then draw the elements on the page (scaled down to 20 percent).
					_thumbnailData[i].draw(_pageContainer[i], new Matrix(0.2, 0, 0, 0.2));
					// Then set the mask again.
					_pageContainer[i].mask = _maskMain[i];
					updateShadowVisibility();
				}
			}
			
			// When only updating thumbnails go no further
			if (forceThumbs) {
				return;
			}
			
			// Check what to do (animating or not)
			if (state == DRAGGING || state == DRAGGING_USER) {
				
				// If close to the traget then do nothing (do not waste cpu time while
				// actually idling).
				if (_dragCurrent.distance(_dragTarget) == 0) {
					return;
				}
				
				// Dragging, get the new _dragTarget via interpolation
				_dragCurrent.interpolate(_dragTarget, _dragSpeed);
				if (_stiff) {
					validatePosition(_dragCurrent, true);
				}
				
			} else if (state == TURNING || state == RESTORING) {
				
				_dragCurrent.copy(_dragFunction.getPosition());
				validatePosition(_dragCurrent);
				
				// Turning or restoring, meaning we move along a path described by the
				// dragpath function. Get the new _dragTarget via the defined function.
				if (_dragFunction.step()) {//(_dragSpeed * _pageWidth * 0.5)) {
					
					// We're done
					if (_state == TURNING) {
						_leftToRight = !_leftToRight;
					}
					resetPage();
					
				}
				
			}
			
			// Update the matrices if not ready, i.e. the page is most likely moving.
			// If the page is ready, the _dragCurrent is probably wrong, so we don't want to do
			// an update.
			if (state != READY) {
				updateMatrices();
			}
			
			// Check if visibility changed, if yes fire an event.
			try {
				if (_pageContainer[0].visible != _pageVisibility[0]) {
					_pageVisibility[0] = _pageContainer[0].visible;
					dispatchEvent(new MegaZineEvent(_pageVisibility[0]
														? MegaZineEvent.VISIBLE_EVEN
														: MegaZineEvent.INVISIBLE_EVEN,
													getNumber(true)));
				}
			} catch (e:Error) { /* _pageContainer[0] == null */ }
			try {
				if (_pageContainer[1].visible != _pageVisibility[1]) {
					_pageVisibility[1] = _pageContainer[1].visible;
					dispatchEvent(new MegaZineEvent(_pageVisibility[1]
														? MegaZineEvent.VISIBLE_ODD
														: MegaZineEvent.INVISIBLE_ODD,
													getNumber(false)));
				}
			} catch (e:Error) { /* _pageContainer[1] == null */ }
			
		}
		
		/**
		 * Updates the matrices for the page and its mask to fit the new drag point
		 */
		private function updateMatrices():void {
			
			var matrix:Matrix = new Matrix();
			var obj:DisplayObject;
			
			if (_stiff) {
				// Current percentual distance to the middle, used frequently in the following.
				var distMid:Number = _dragCurrent.x / _pageWidth - 1;
				
				// Right page (even)
				matrix.a = distMid < 0 ? 0 : distMid;
				matrix.b = _dragCurrent.y / _pageHeight;
				matrix.tx = _pageWidth;
				_pageContainer[0].transform.matrix = matrix;
				
				// Left page (odd)
				matrix.a = distMid > 0 ? 0 : distMid;
				matrix.a = matrix.a < 0 ? -matrix.a : matrix.a;
				matrix.b *= -1;
				matrix.tx = _dragCurrent.x;
				matrix.ty = _dragCurrent.y * _pageWidth / _pageHeight;
				_pageContainer[1].transform.matrix = matrix;
				
				if (_shadows) {
					// Shadows (no highlights for stiff pages)
					if (_mz.shadows) {
						_shadows[0].visible = false;
						_shadows[1].visible = false;
						
						// Matrix for the dropped shadow
						matrix.identity();
						matrix.scale(distMid, 1);
						matrix.tx = _pageWidth;
						
						//id = distMid > 0 ? 0 : 1;
						obj = _shadows[distMid > 0 ? 0 : 1];
						obj.transform.matrix = matrix;
						obj.visible = true;
						obj.alpha = distMid < 0 ? -distMid : distMid;
					} else {
						// Don't use _shadows
						_shadows[0].visible = false;
						_shadows[1].visible = false;
					}
				}
			} else {
				// First get the vector between the reference point and the current point.
				var v:Vector2D = _dragCurrent.minus(_dragReference);
				
				// Make sure the vector has a minimal length
				// Actually we'd only need to do this if y is 0 as well, but as this can actually
				// only happen in the very beginning (because afterwards the _keepDistance
				// kicks in) it doesn't really matter. And even if keepdist was set to 0, the
				// jump is less than tiny. It's unrecognizable.
				if (_leftToRight) {
					v.x ||= 0.1;
				} else {
					v.x ||= -0.1;
				}
				
				// Base corners off of the middle of the reference and the current point.
				var corner:Vector2D = _dragReference.clone().interpolate(_dragCurrent);
				
				// The angle to rotate the matrix
				var angle:Number = Math.atan2(v.y, v.x);
				
				// For the moving page
				
				// !!! The order matters, because of the rotation around the origin!
				// Move it up by the offset to rotate it, then move it to the actual position.
				// If it's the even page we need to move it a tad to the left.
				matrix.translate(_leftToRight ? -_pageWidth : 0, -_dragOffset);
				// Rotate it.
				matrix.rotate(angle * 2);
				// Move it back down and then to the drag point
				matrix.translate(_dragCurrent.x, _dragCurrent.y);
				
				// For the page's mask
				
				// Check which way we turn (we could also use isEven, because left to right
				// always means we drag an even page, right to left always an odd one).
				if (_leftToRight) {
					// Add the masks height / 2, in the proper direction.
					corner.plusEquals(v.lhn().normalize(_maskMain[0].height * 0.5));
				} else {
					// Add the masks height / 2, in the proper direction.
					corner.minusEquals(v.rhn().normalize(_maskMain[0].height * 0.5));
				}
				
				// Apply the new matrix
				if (_leftToRight) {
					_pageContainer[0].transform.matrix = matrix;
				} else {
					_pageContainer[1].transform.matrix = matrix;
				}
				
				// !!! Again, order matters!
				// Reset the matrix
				matrix.identity();
				// Rotate the matrix
				matrix.rotate(angle);
				// And move it to the corner
				matrix.translate(corner.x, corner.y);
				
				_maskMain[0].transform.matrix = matrix;
				_maskMain[1].transform.matrix = matrix;
				
				// Shadow / Highlight
				if (_shadows) {
					if (_mz.shadows) {
						
						var middle:Point = new Point(_dragCurrent.x - v.x  * 0.5,
													 _dragCurrent.y - v.y  * 0.5);
						
						// Calculate the final position (where the drag would end)
						v.setTo(_leftToRight ? _pageWidth * 2 : 0, _dragOffset);
						
						// The scaling factor for the shadow / highlight, depends on how far
						// the dragpoint is away from the beginning. Begins with 0
						// (_dragCurrent == start) and ends with 1 (_dragCurrent is two times
						// the _pageWidth away from the start).
						var scale:Number = 1 - v.distance(_dragCurrent) / (_pageWidth * 2);
						
						// Minimum scale
						scale = scale < 0.1 ? 0.1 : scale;
						
						// Calculate alpha values (quickly become visible, then be 100% for a
						// time, and in the end quickly fade out again)
						var alpha:Number = (scale < 0.90
												? (scale * 20)
												: 1 - (20 * (scale - 0.90)));
						alpha = alpha > 1 ? 1 : alpha;
						
						// Begin fading after 50%
						var alpha2:Number = (scale < 0.5 ? alpha : 1 - (2 * (scale - 0.5)));
						alpha2 = alpha2 > 1 ? 1 : alpha2;
						
						// Apply maxima
						alpha *= _shadowAlpha;
						alpha2 *= _shadowAlpha;
						
						// Matrix for the dropped shadow
						matrix.identity();
						matrix.scale(scale, 2);
						matrix.rotate(angle);
						matrix.translate(middle.x, middle.y);
						
						obj = _shadows[_leftToRight ? 0 : 1]
						obj.transform.matrix = matrix;
						obj.alpha = alpha;
						obj.visible = true;
						
						// Matrix for the highlight
						matrix.identity();
						matrix.scale(scale, 2);
						matrix.rotate(-angle);
						middle = _pageContainer[_leftToRight ? 0 : 1].globalToLocal(
																	_mz.localToGlobal(middle));
						matrix.translate(middle.x, middle.y);
						
						obj = _shadows[_leftToRight ? 2 : 3]
						obj.transform.matrix = matrix;
						obj.alpha = alpha2;
						obj.visible = true;
						
					} else {
						// Don't use _shadows
						_shadows[0].visible = false;
						_shadows[1].visible = false;
						_shadows[2].visible = false;
						_shadows[3].visible = false;
					}
				}
			}
			
		}
		
		/**
		 * Check which _shadows / highlights to enable and which to disable
		 */
		private function updateShadowVisibility():void {
			
			// Don't do anything if _shadows are disabled or there are no _shadows / highlights.
			if (_mz.shadows && _shadows) {
				if (state != READY) {
					// Page is dragged, show _shadows
					if (_leftToRight) {
						_shadows[0].visible = true;
						if (!_stiff) {
							_shadows[2].visible = true;
						}
					} else {
						_shadows[1].visible = true;
						if (!_stiff) {
							_shadows[3].visible = true;
						}
					}
				} else {
					// Page is static, hide all _shadows / highlights
					_shadows[0].visible = false;
					_shadows[1].visible = false;
					if (!_stiff) {
						_shadows[2].visible = false;
						_shadows[3].visible = false;
					}
				}
			}
			
		}
		
		/**
		 * Validate a Vector's location (for _dragTarget, so no impossible page positions happen)
		 * @param _dragTarget The vector to check
		 * @param yOnly Only validates the y position based on the x position (for stiff pages)
		 */
		private function validatePosition(v:Vector2D, yOnly:Boolean = false):void {
			
			var tmp:Number;
			
			// Add the distance to keep from the border if manually dragging.
			if (!yOnly && (state == DRAGGING || state == DRAGGING_USER)) {
				if (_leftToRight) {
					v.x = _keepDistance < v.x ? v.x : _keepDistance;
				} else {
					tmp = _pageWidth * 2 - _keepDistance;
					v.x = tmp > v.x ? v.x : tmp;
				}
			}
			
			if (_stiff) {
				// Check for stiff pages. This is pretty easy, because the pages can only move
				// on a fixed arc. We just calculate the y value, so we only need to validate
				// the x value.
				tmp = _pageWidth * 2;
				v.x = tmp > v.x ? v.x : tmp;
				v.x = v.x < 0 ? 0 : v.x;
				// Calculate y.
				// Let a = Angle between v.x and _dragReferenceTopMiddle
				// x = Math.cos(a) * _pageWidth + _pageWidth
				// y = - Math.sin(a) * (_pageDiagonale - _pageHeight)
				// With x as the variable this gives us:
				// a = Math.acos(x / _pageWidth - 1)
				// y = - Math.sin(Math.acos(x / _pageWidth - 1)) * (_pageDiagonale - _pageHeight)
				// As for the final correction factor... I don't know where that comes from, and
				// am too lazy to find out. After all, it works.
				v.y = -Math.sin(Math.acos(v.x / _pageWidth - 1)) * (_pageDiagonale - _pageHeight)
					* _pageHeight / _pageWidth;
			} else {
				// A normal page. Check the distance from the top reference point, being in the
				// top middle. The allowed distance is determined when starting to drag the page
				// and is either the page width if the corner is a top corner, or the page
				// diagonale if it is a bottom corner.
				var d:Number = v.distance(_dragReferenceTopMiddle);
				if (d > _dragMaxDistTop) {
					v.interpolate(_dragReferenceTopMiddle, 1 - _dragMaxDistTop / d);
				}
				// Same as for the top middle reference point, just for the bottom (vice versa).
				d = v.distance(_dragReferenceBottomMiddle);
				if (d > _dragMaxDistBottom) {
					v.interpolate(_dragReferenceBottomMiddle, 1 - _dragMaxDistBottom / d);
				}
				
			}
			
		}
		
	}
	
}
