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
	
	import com.adobe.utils.DictionaryUtil;
	import de.mightypirates.megazine.*;
	import de.mightypirates.megazine.events.MegaZineEvent;
	import de.mightypirates.utils.*;
	import flash.errors.IOError;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.*;
	
	/**
	 * This is the zoom overlay that can be opened for any image.
	 * 
	 * @author fnuecke
	 */
	public class ZoomContainer extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** Currently not dragging */
		private static const DRAG_NONE:String = "drag_none";
		
		/** Currently dragging the image */
		private static const DRAG_IMAGE:String = "drag_image";
		
		/** Currently dragging the rectangle across the thumbnail */
		private static const DRAG_THUMB:String = "drag_thumb";
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The main background */
		private var _bg:DisplayObject;
		
		/** The button for closing the zoom mode */
		private var _btnClose:SimpleButton;
		
		/**
		 * The container for the image (makes dragging and positioning the image a lot easier)
		 */
		private var _container:Sprite;
		
		/** Currently loaded and displayed image */
		private var _currImg:DisplayObject;
		
		/** The rectangle for dragging the view across the thumbnail */
		private var _dragRect:Sprite;
		
		/** Current drag state */
		private var _dragState:String = DRAG_NONE;
		
		/** Thumbnail fading timer */
		private var _fadeTimer:Timer;
		
		/** Target alpha of the fader */
		private var _fadeTarget:Number;
		
		/** Currently opened gallery */
		private var _gallery:Dictionary; // Array
		
		/** Number of the image in the page array */
		private var _galleryImage:int;
		
		/** Container for next image in the gallery button */
		private var _galleryNext:SimpleButton;
		
		/** Container for previous image in the gallery button */
		private var _galleryPrev:SimpleButton;
		
		/** Name of the page with the current image */
		private var _galleryPage:int = -1;
		
		/** The original and unscaled height of the loaded image */
		private var _imageHeight:Number;
		
		/** Loader used to load the image */
		private var _imageLoader:Loader;
		
		/** The original and unscaled width of the loaded image */
		private var _imageWidth:Number;
		
		/** The loading bar */
		private var _loading:LoadingBar;
		
		/** The mask for the container */
		private var _mask:Shape;
		
		/** Mask for the dragrect (so it does not overflow the thumbnail area) */
		private var _maskDragRect:Shape;
		
		/** Normal height for non fullscreen mode */
		private var _normalHeight:Number;
		
		/** Normal width for non fullscreen mode */
		private var _normalWidth:Number;
		
		/** Restraint rectangle for dragging the container. */
		private var _rectContainer:Rectangle;
		
		/** Restraing rectangle for the dragging the dragrect. */
		private var _rectDragRect:Rectangle;
		
		/** Current scaling factor of the thumbnail */
		private var _scale:Number;
		
		/** Actual base height of the scaled image (thumbnail) */
		private var _scaledHeight:Number;
		
		/** Actual base width of the scaled image (thumbnail) */
		private var _scaledWidth:Number;
		
		/** The background for the thumbnail view */
		private var _thumbBackground:DisplayObject;
		
		/** The bitmap to display the thumbnail */
		private var _thumbBitmap:Bitmap;
		
		/** Thumbnail bitmapdata */
		private var _thumbData:BitmapData;
		
		/** Container for the thumbnail view */
		private var _thumbView:DisplayObjectContainer;
		
		/** Current zoom level. */
		private var _zoom:Number = 1.0;
		
		/**
		 * Minimum zoom level - this gets set so that when zoomed out completely the whole
		 * image fits onto the available area.
		 */
		private var _zoomMin:Number = 0.5;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new zoom container.
		 * @param mz The owning megazine (used solely to get localization strings)
		 * @param width The normal width, when not in fullscreen.
		 * @param height The normal height, when not in fullscreen.
		 * @param lib The graphics library to use for getting images.
		 */
		public function ZoomContainer(mz:MegaZine, width:uint, height:uint,
									  loc:Localizer, lib:Library) {
			// Hide initially
			visible = false;
			
			// Thumbnail fader
			_fadeTimer = new Timer(30);
			
			// Base background
			_bg = lib.getInstanceOf(LibraryConstants.BACKGROUND) as DisplayObject;
			addChild(_bg);
			
			// Loading bar
			_loading = new LoadingBar(lib, loc);
			addChild(_loading);
			
			// Main container
			_mask = new Shape();
			addChild(_mask);
			_container = new Sprite();
			_container.mask = _mask;
			addChild(_container);
			
			// Thumbnail view setup
			_thumbView = new Sprite();
			_thumbBackground = lib.getInstanceOf(LibraryConstants.BACKGROUND) as DisplayObject;
			_thumbBackground.y = 10;
			_thumbView.addChild(_thumbBackground);
			_maskDragRect = new Shape();
			_maskDragRect.y = _thumbBackground.y;
			_thumbView.addChild(_maskDragRect);
			_dragRect = new Sprite();
			_dragRect.mask = _maskDragRect;
			_dragRect.buttonMode = true;
			_thumbView.addChild(_dragRect);
			_btnClose = lib.getInstanceOf(LibraryConstants.BUTTON_CLOSE) as SimpleButton;
			_btnClose.y = 10;
			_thumbView.addChild(_btnClose);
			_thumbView.alpha = 0.25;
			addChild(_thumbView);
			
			// Gallery navigation buttons
			var tt:ToolTip;
			_galleryNext =
						lib.getInstanceOf(LibraryConstants.BUTTON_ARROW_RIGHT) as SimpleButton;
			_galleryNext.addEventListener(MouseEvent.CLICK, onGalleryNext);
			tt = new ToolTip("", _galleryNext);
			loc.registerObject(tt, "text", "LNG_ZOOM_NEXT");
			
			_galleryPrev = lib.getInstanceOf(LibraryConstants.BUTTON_ARROW_LEFT) as SimpleButton;
			_galleryPrev.addEventListener(MouseEvent.CLICK, onGalleryPrev);
			tt = new ToolTip("", _galleryPrev);
			loc.registerObject(tt, "text", "LNG_ZOOM_PREV");
			
			// Hide initially
			_galleryNext.visible = false;
			_galleryPrev.visible = false;
			
			_thumbView.addChild(_galleryNext);
			_thumbView.addChild(_galleryPrev);
			
			// Event listeners
			addEventListener(Event.ADDED_TO_STAGE, registerListeners);
			
			// Set base width and height
			_normalWidth = width;
			_normalHeight = height;
			
			// Set tooltip for close button
			tt = new ToolTip("", _btnClose);
			loc.registerObject(tt, "text", "LNG_ZOOM_EXIT");
			
			// Set sizes
			setSizes(width, height);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Event listeners
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Set up listeners as soon as this object is added to the stage.
		 * @param e unused.
		 */
		private function registerListeners(e:Event):void {
			// Only once.
			removeEventListener(Event.ADDED_TO_STAGE, registerListeners);
			addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			// Dragging of the big image / container
			_container.addEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			_dragRect.addEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onDragStop);
			// Keyboard controls for gallery navigation
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			// Exit
			_btnClose.addEventListener(MouseEvent.CLICK, exitZoom);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, exitZoom);
			// Zoom
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onUserZoom);
			// Fullscreen entering/leaving handling
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onChangeFullscreen);
			// Fader of the thumbnail view
			_thumbView.addEventListener(MouseEvent.MOUSE_OVER, onFadeIn);
			_thumbView.addEventListener(MouseEvent.MOUSE_OUT, onFadeOut);
			// Actual fade timer
			_fadeTimer.addEventListener(TimerEvent.TIMER, onFadeTimer);
			
			// Reset sizes if in fullscreen.
			if (stage["displayState"] != undefined
				&& stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				setSizes(stage["fullScreenWidth"], stage["fullScreenHeight"]);
			}
		}
		
		/**
		 * Kill all listeners when removed from the stage.
		 * @param e unused.
		 */
		private function removeListeners(e:Event):void {
			_container.removeEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			_dragRect.removeEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDragStop);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			_btnClose.removeEventListener(MouseEvent.CLICK, exitZoom);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, exitZoom);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onUserZoom);
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onChangeFullscreen);
			_thumbView.removeEventListener(MouseEvent.MOUSE_OVER, onFadeIn);
			_thumbView.removeEventListener(MouseEvent.MOUSE_OUT, onFadeOut);
			_fadeTimer.removeEventListener(TimerEvent.TIMER, onFadeTimer);
		}
		
		/**
		 * Update the drag position.
		 * @param e unused.
		 */
		private function onDragMove(e:MouseEvent):void {
			if (_dragState == DRAG_IMAGE) {
				updateDragRectPos();
			} else if (_dragState == DRAG_THUMB) {
				updateImagePos();
			}
		}
		
		/**
		 * Start dragging.
		 * @param e unused.
		 */
		private function onDragStart(e:MouseEvent):void {
			if (_dragState == DRAG_NONE) {
				if (e.target == _container) {
					_container.startDrag(false, _rectContainer);
					_dragState = DRAG_IMAGE;
				} else if (e.target == _dragRect) {
					_dragRect.startDrag(false, _rectDragRect);
					_dragState = DRAG_THUMB;
				}
			}
		}
		
		/**
		 * Stop dragging.
		 * @param e unused.
		 */
		private function onDragStop(e:MouseEvent):void {
			_container.stopDrag();
			_dragRect.stopDrag();
			_dragState = DRAG_NONE;
		}
		
		/**
		 * Update the zoom ratio.
		 * @param e used to determine whether to increase or to decrease the ratio.
		 */
		private function onUserZoom(e:MouseEvent):void {
			if (!visible) return;
			var stepSize:Number = (1.0 - _zoomMin) * 0.2;
			if (e.delta < 0) {
				// Out
				_zoom = Math.max(_zoomMin, _zoom - stepSize);
			} else {
				// In
				_zoom = Math.min(1.0, _zoom + stepSize);
			}
			if (Math.abs(_zoom - _zoomMin) < 0.01) {
				_zoom = _zoomMin;
			} else if (Math.abs(_zoom - 1.0) < 0.01) {
				_zoom = 1.0;
			}
			updateZoom();
		}
		
		/**
		 * Leave zoom mode.
		 * @param e if KeyboardEvent used to determined whether it was the escape key.
		 */
		private function exitZoom(e:Event = null):void {
			if (!(e is KeyboardEvent) || (e as KeyboardEvent).keyCode == Keyboard.ESCAPE) {
				hide();
			}
		}
		
		/**
		 * Start fading the thumbnail in.
		 * @param e unused.
		 */
		private function onFadeIn(e:Event):void {
			_fadeTarget = 1.0;
			_fadeTimer.start();
		}
		
		/**
		 * Start fading the thumbnail out.
		 * @param e unused.
		 */
		private function onFadeOut(e:Event):void {
			_fadeTarget = 0.25;
			_fadeTimer.start();
		}
		
		/**
		 * Handle timer event for thumbnail fading.
		 * @param e unused.
		 */
		private function onFadeTimer(e:TimerEvent):void {
			if (Math.abs(_fadeTarget - _thumbView.alpha) < 0.1) {
				_thumbView.alpha = _fadeTarget;
				_fadeTimer.stop();
			} else if (_fadeTarget > _thumbView.alpha) {
				_thumbView.alpha += 0.1;
			} else if (_fadeTarget < _thumbView.alpha) {
				_thumbView.alpha -= 0.1;
			}
		}
		
		/**
		 * Fired when the right arrow is pressed, show next image in the gallery.
		 * @param e unused.
		 */
		private function onGalleryNext(e:MouseEvent):void {
			if (_gallery == null) {
				return;
			}
			var oldPage:int = _galleryPage, oldImage:uint = _galleryImage;
			if (_galleryImage - 1 < 0) {
				// Has next page?
				var keys:Array = DictionaryUtil.getKeys(_gallery);
				var next:int = keys.indexOf(_galleryPage) + 1;
				if (keys.length <= next) {
					// No, rewind
					_galleryPage = keys[0];
				} else {
					// Next page
					_galleryPage = keys[next];
				}
				// First in that page (stored reversely due to pushing)
				_galleryImage = _gallery[_galleryPage].length - 1;
			} else {
				// Next in current page (stored reversely due to pushing)
				_galleryImage--;
			}
			if (_galleryPage == oldPage && _galleryImage == oldImage) {
				// No change...
				return;
			}
			display(_gallery[_galleryPage][_galleryImage], true);
		}
		
		/**
		 * Fired when the left arrow is pressed, show previous image in the gallery.
		 * @param e unused.
		 */
		private function onGalleryPrev(e:MouseEvent):void {
			if (_gallery == null) {
				return;
			}
			var oldPage:int = _galleryPage, oldImage:uint = _galleryImage;
			if (_galleryImage + 1 >= _gallery[_galleryPage].length) {
				// Has prev page?
				var keys:Array = DictionaryUtil.getKeys(_gallery);
				var prev:int = keys.indexOf(_galleryPage) - 1;
				if (prev < 0) {
					// No, go to end
					_galleryPage = keys[keys.length - 1];
				} else {
					// Next page
					_galleryPage = keys[prev];
				}
				// Last in that page array (stored reversely due to pushing)
				_galleryImage = 0;
			} else {
				// Prev in current page (stored reversely due to pushing)
				_galleryImage++;
			}
			if (_galleryPage == oldPage && _galleryImage == oldImage) {
				// No change...
				return;
			}
			display(_gallery[_galleryPage][_galleryImage], true);
		}
		
		/**
		 * All keypresses go here, triggering possible gallery navigation.
		 * @param e Event data
		 */
		private function onKeyPressed(e:KeyboardEvent):void {
			
			// Only if the pages are already visible.
			if (!visible || _gallery == null) {
				return;
			}
			
			// Check what to do
			switch(e.keyCode) {
				case Keyboard.LEFT:
					onGalleryPrev(null);
					break;
				case Keyboard.RIGHT:
					onGalleryNext(null);
					break;
			}
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Fullscreen mode changed. Update sizes.
		 * @param e used to test which mode we are in now.
		 */
		private function onChangeFullscreen(e:FullScreenEvent):void {
			try {
				// Set new sizes
				if (e.fullScreen) {
					setSizes(stage["fullScreenWidth"], stage["fullScreenHeight"]);
					// If zoom mode is active redraw the thumbnail
					if (visible) {
						updateThumb();
					}
				} else {
					setSizes(_normalWidth, _normalHeight);
					hide();
				}
			} catch (e:Error) {
				Logger.log("MegaZine Zoom", "Error handling fullscreen change: " + e.toString(),
						   Logger.TYPE_WARNING);
			}
		}
		
		/**
		 * Set size of thumbnail and main container based on allowed limits.
		 * @param width Allowed width.
		 * @param height Allowed height.
		 */
		private function setSizes(width:int, height:int):void {
			// Position background and self
			_bg.width = width;
			_bg.height = height;
			
			x = (_normalWidth - width) * 0.5;
			y = (_normalHeight - height) * 0.5;
			
			// Position loading bar
			_loading.x = (_bg.width - _loading.baseWidth) * 0.5;
			_loading.y = (_bg.height - _loading.height) * 0.5;
			
			// Position close button and assign function
			_btnClose.x = width - 10 - _btnClose.hitTestState.width;
			
			// Scale and position thumbnail background
			_thumbBackground.width = _btnClose.hitTestState.width;
			_thumbBackground.height = _btnClose.hitTestState.height;
			_thumbBackground.x = _btnClose.x + (_btnClose.width - _btnClose.hitTestState.width);
			
			// Masking to the visible area.
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xFF00FF);
			_mask.graphics.lineStyle();
			_mask.graphics.drawRect(0, 0, width, height);
			_mask.graphics.endFill();
			
			// Drawing of the dragrect
			_dragRect.graphics.clear();
			_dragRect.graphics.beginFill(0xFFFFFF, 0.5);
			_dragRect.graphics.lineStyle(1, 0x000000, 0.6, true, LineScaleMode.NONE)
			_dragRect.graphics.lineTo(width, 0);
			_dragRect.graphics.lineTo(width, height);
			_dragRect.graphics.lineTo(0, height);
			_dragRect.graphics.lineTo(0, 0);
			_dragRect.graphics.endFill();
		}
		
		/**
		 * Update the dragging rectangle's position, e.g. when dragging the actual image.
		 */
		private function updateDragRectPos():void {
			_dragRect.x = Math.round(_thumbBitmap.x + (_thumbBitmap.width - _dragRect.width)
													* 0.5 - _container.x * _dragRect.scaleX);
			_dragRect.y = Math.round(_thumbBitmap.y + (_thumbBitmap.height - _dragRect.height)
													* 0.5 - _container.y * _dragRect.scaleX);
			// Enforce restraints
			_dragRect.x = Math.min(Math.max(_dragRect.x, _rectDragRect.x), _rectDragRect.right);
			_dragRect.y = Math.min(Math.max(_dragRect.y, _rectDragRect.y), _rectDragRect.bottom);
		}
		
		/**
		 * Update the image's position, e.g. when dragging the rectangle on top of the thumbnail.
		 */
		private function updateImagePos():void {
			// Inverse of updateDragRectPos...
			_container.x = Math.round((_thumbBitmap.x + (_thumbBitmap.width - _dragRect.width)
													  * 0.5 - _dragRect.x) / _dragRect.scaleX);
			_container.y = Math.round((_thumbBitmap.y + (_thumbBitmap.height - _dragRect.height)
													  * 0.5 - _dragRect.y) / _dragRect.scaleX);
			// Enforce restraints
			_container.x = Math.min(Math.max(_container.x, _rectContainer.x),
									_rectContainer.right);
			_container.y = Math.min(Math.max(_container.y, _rectContainer.y),
									_rectContainer.bottom);
		}
		
		/**
		 * Update image preview and limits based on loaded image.
		 * Also updates zoom, because the zoom is dependant on the scaling factor
		 * calculated here.
		 */
		private function updateThumb():void {
			// Create and position thumbnail
			if (_thumbData) {
				_thumbData.dispose();
				_thumbData = null;
			}
			if (_thumbBitmap) {
				_thumbView.removeChild(_thumbBitmap);
				_thumbBitmap = null;
			}
			// If we have no image, cancel...
			if (!_currImg) {
				return;
			}
			_thumbData = new BitmapData(Math.round(Math.max(_bg.width / 5, _bg.height / 5)) - 20,
										Math.round(Math.max(_bg.width / 5, _bg.height / 5)) - 20,
										true, 0x00000000);
			_thumbBitmap = new Bitmap(_thumbData);
			_thumbBitmap.x = _bg.width - _thumbData.width - 20;
			_thumbBitmap.y = _thumbBackground.y + 10;
			
			_thumbView.addChildAt(_thumbBitmap, 1);
			
			// Paint thumbnail
			_scale = Math.min(1, Math.min(_thumbData.width / _imageWidth,
										  _thumbData.height / _imageHeight));
			_scaledWidth = int(_scale * _imageWidth);
			_scaledHeight = int(_scale * _imageHeight);
			_thumbData.draw(_currImg,
							// Scaling matrix.
							new Matrix(_scale, 0, 0, _scale,
									   int((_thumbData.width - _scaledWidth) * 0.5),
									   int((_thumbData.height - _scaledHeight) * 0.5)),
							// No colortransform and no blendmode.
							null, null,
							// Clipping rectangle for clean cutoff.
							new Rectangle(int((_thumbData.width - _scaledWidth) * 0.5),
										  int((_thumbData.height - _scaledHeight) * 0.5),
										  _scaledWidth, _scaledHeight),
							// Smooth the outcome.
							true);
			// Reset container positioning
			_container.x = 0;
			_container.y = 0;
			
			// Calculate zoom level required.
			_zoomMin = Math.min(1.0, _bg.width / _imageWidth, _bg.height / _imageHeight);
			if (Math.abs(_zoomMin - 1.0) < 0.01) {
				_zoomMin = 1.0;
			}
			// Don't let the zoom be smaller than the min zoom
			_zoom = Math.max(_zoom, _zoomMin);
			// Snap to full or min zoom
			if (Math.abs(_zoom - _zoomMin) < 0.01) {
				_zoom = _zoomMin;
			} else if (Math.abs(_zoom - 1.0) < 0.01) {
				_zoom = 1.0;
			}
			
			// Update zoom.
			updateZoom();
			
		}
		
		private function updateZoom():void {
			// Scale and position acutal image
			_currImg.scaleX = _zoom;
			_currImg.scaleY = _zoom;
			_currImg.width = Math.round(_currImg.width);
			_currImg.height = Math.round(_currImg.height);
			_currImg.x = Math.round((_bg.width - _imageWidth * _zoom) * 0.5);
			_currImg.y = Math.round((_bg.height - _imageHeight * _zoom) * 0.5);
			// Update the dragrect size
			var dragScale:Number = _scale / _zoom;
			_dragRect.scaleX = dragScale;
			_dragRect.scaleY = dragScale;
			_dragRect.width = Math.round(_dragRect.width);
			_dragRect.height = Math.round(_dragRect.height);
			
			// Show hand cursor when the image can be dragged / scrolled. If not hide thumbnail.
			var showHand:Boolean = _imageWidth * _zoom > _bg.width
								|| _imageHeight * _zoom > _bg.height;
			_container.buttonMode = showHand;
			_thumbBitmap.visible  = showHand;
			_dragRect.visible     = showHand;
			
			// Update the constraint rectangle for dragging.
			_rectContainer = new Rectangle(Math.min(0, (_bg.width - _imageWidth * _zoom)*0.5),
										   Math.min(0, (_bg.height - _imageHeight * _zoom)*0.5),
										   Math.max(0, (_imageWidth * _zoom - _bg.width)),
										   Math.max(0, (_imageHeight * _zoom - _bg.height)));
			_rectDragRect = new Rectangle(Math.min((_thumbBitmap.x + (_thumbBitmap.width
																	  - _scaledWidth) * 0.5),
												   (_thumbBitmap.x + (_thumbBitmap.width
												   					  - _dragRect.width) * 0.5)),
										  Math.min((_thumbBitmap.y + (_thumbBitmap.height
										  							  - _scaledHeight) * 0.5),
												   (_thumbBitmap.y + (_thumbBitmap.height
																	 - _dragRect.height) * 0.5)),
										  Math.max(0, _scaledWidth - _dragRect.width),
										  Math.max(0, _scaledHeight - _dragRect.height));
			
			// Enforce constraints
			_container.x = Math.min(Math.max(_rectContainer.x, _container.x),
									_rectContainer.right);
			_container.y = Math.min(Math.max(_rectContainer.y, _container.y),
									_rectContainer.bottom);
			
			// Position the dragging rectangle
			updateDragRectPos();
			
			updateThumbBox();
			
			_maskDragRect.graphics.clear();
			_maskDragRect.graphics.beginFill(0xFF00FF);
			_maskDragRect.graphics.lineStyle();
			_maskDragRect.graphics.drawRect(0, 0, _thumbBackground.width,
											_thumbBackground.height);
			_maskDragRect.graphics.endFill();
			_maskDragRect.x = _thumbBackground.x;
			
		}
		
		private function updateThumbBox():void {
			// Test if the thumbnail needs showing
			if (_currImg && (_imageWidth * _zoom > _bg.width
							 || _imageHeight * _zoom > _bg.height))
			{
				// Thumbnail needed
				_thumbBackground.width  = Math.round(Math.max(_bg.width / 5, _bg.height / 5));
				_thumbBackground.height = _thumbBackground.width;
				_thumbBackground.x = _bg.width - 10 - _thumbBackground.width;
				// Position gallery buttons
				_galleryNext.x = _thumbBackground.x + _thumbBackground.width
								 - _galleryNext.hitTestState.width;
				_galleryNext.y = _thumbBackground.y + _thumbBackground.height
								 - _galleryNext.hitTestState.height;
				_galleryPrev.x = _thumbBackground.x;
				_galleryPrev.y = _thumbBackground.y + _thumbBackground.height
								 - _galleryPrev.hitTestState.height;
			} else {
				// No thumbnail needed
				_thumbBackground.width = _btnClose.hitTestState.width;
				_thumbBackground.height = _btnClose.hitTestState.height;
				if (_galleryNext.visible) {
					_thumbBackground.width += _galleryNext.hitTestState.width
											  + _galleryPrev.hitTestState.width;
					_thumbBackground.height = Math.max(_thumbBackground.height,
													   _galleryPrev.hitTestState.height,
													   _galleryNext.hitTestState.height);
				}
				_thumbBackground.x = _bg.width - 10 - _thumbBackground.width;
				// Position gallery buttons
				_galleryNext.x = _thumbBackground.x + _galleryPrev.hitTestState.width;
				_galleryNext.y = _thumbBackground.y;
				_galleryPrev.x = _thumbBackground.x;
				_galleryPrev.y = _thumbBackground.y;
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Might be set if the image that should be displayed is part of a gallery.
		 * @param gallery Array with all pages and all images in this gallery.
		 * @param currPage The page containing the currently displayed image.
		 * @param currNum The number of the currently displayed image in the array for
		 * the images of its page.
		 */
		public function setGalleryData(gallery:Dictionary, currPage:uint, currNum:uint):void {
			_gallery = gallery;
			_galleryPage = currPage;
			_galleryImage = currNum;
			_galleryNext.visible = true;
			_galleryPrev.visible = true;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Display / Hide
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Display the given image.
		 * @param path The path to the image to display.
		 * @param keepZoom Keep the zoom ration.
		 */
		public function display(path:String, keepZoom:Boolean = false):void {
			// Avoid nullpointers...
			if (path == null) {
				return;
			}
			
			// Reset zoom
			if (!keepZoom) {
				_zoom = 1.0;
			}
			
			// Kill previous images, to allow consecutive execution of this method.
			unloadImage();
			
			// Initially don't show the dragging rectangle
			_dragRect.visible = false;
			updateThumbBox();
			
			// Show loading bar
			_loading.visible = true;
			
			// Show self
			visible = true;
			
			// Try loading the image, on failure hide self
			try {
				try {
					if (_imageLoader) {
						// Cancel loading if still loading
						_imageLoader.close();
					}
					_imageLoader = null;
				} catch (ex:Error) { }
				_imageLoader = new Loader();
				_imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,
															    onProgress);
				_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
				_imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				_imageLoader.load(new URLRequest(path));
			} catch (ex:SecurityError) {
				Logger.log("MegaZine Zoom", "Could not load highres image from path '"
											+ Helper.trimString(path, 40)
						 					+ "' due to a security error.", Logger.TYPE_WARNING);
				_loading.visible = false;
				_imageLoader.close();
				_imageLoader = null;
			}
		}
		
		/**
		 * Error loading the image...
		 * @param	e
		 */
		private function onError(e:IOErrorEvent):void {
			Logger.log("MegaZine Zoom",
					   "Error loading highres image, probably the filename/url is wrong.",
					   Logger.TYPE_WARNING);
			_imageLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
			_imageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loading.visible = false;
			try {
				_imageLoader.close();
			} catch (ex:Error) { }
			_imageLoader = null;
		}
		
		/**
		 * Making progress while loading the image.
		 * @param e used to get the percentual progress.
		 */
		private function onProgress(e:ProgressEvent):void {
			var p:Number = e.bytesLoaded / e.bytesTotal;
			try {
				_loading.percent = p;
			} catch (e:Error) {}
		}
		
		/**
		 * Image loaded completely!
		 * @param e used to get the loaded image from the loader.
		 */
		private function onLoaded(e:Event):void {
			_imageLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
			_imageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loading.visible = false;
			// OK, save in variable, position and add
			_imageWidth = _imageLoader.width;
			_imageHeight = _imageLoader.height;
			_currImg = _imageLoader.getChildAt(0);
			
			// No longer needed
			try {
				_imageLoader.close();
			} catch (ex:Error) {}
			_imageLoader = null;
			
			_container.addChild(_currImg);
			
			// Smoothing for different zoom steps
			if (_currImg is Bitmap) {
				(_currImg as Bitmap).smoothing = true;
			}
			
			updateThumb();
		}
		
		/**
		 * Hide the zoom.
		 */
		private function hide():void {
			if (visible) {
				unloadImage();
				// Hide self
				visible = false;
				_galleryNext.visible = false;
				_galleryPrev.visible = false;
				_galleryImage = 0;
				_gallery = null;
				dispatchEvent(new MegaZineEvent(MegaZineEvent.ZOOM_CLOSED, _galleryPage));
				_galleryPage = -1;
			}
		}
		
		/**
		 * Unload the current image, consequently clearing the display.
		 * Resets thumbnail areas size to min.
		 */
		private function unloadImage():void {
			// Remove image
			if (_currImg) {
				_container.removeChild(_currImg);
			}
			// Clear thumbnail
			if (_thumbBitmap) {
				_thumbView.removeChild(_thumbBitmap);
			}
			// And thumbnail data
			if (_thumbData) {
				_thumbData.dispose();
			}
			_currImg = null;
			_thumbBitmap = null;
			_thumbData = null;
			try {
				_loading.percent = 0;
			} catch (e:Error) { }
		}
		
	}
	
}