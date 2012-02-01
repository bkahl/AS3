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
	
	import de.mightypirates.megazine.*;
	import de.mightypirates.megazine.events.*;
	import de.mightypirates.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.utils.Timer;
	
	/**
	 * The navigation bar.
	 * 
	 * @author fnuecke
	 */
	public class Navigation extends Sprite {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** Size of buttons (height and width must be equal) */
		private static const BUTTON_SIZE:Number = 24.0;
		
		/** Size of page buttons (width, height is same as normal buttons) */
		private static const BUTTON_PAGE_SIZE:Number = 16.0;
		
		/** Spacing between the page numbers and the navigation (minimum) */
		private static const SPACING:Number = 20.0;
		
		/** Border of the thumbnail window */
		private static const THUMB_BORDER:Number = 10.0;
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Background image - needed here for resizing */
		private var _bg:DisplayObject;
		
		/** Container for all buttons (for masking) */
		private var _buttons:DisplayObjectContainer;
		
		/** Glowfilter for page button of the active page */
		private var _glow:GlowFilter;
		
		/** Mask for hiding additional button rows */
		private var _mask:Shape;
		
		/** Maximum mask height */
		private var _maskHeightMax:Number;
		
		/** Minimum mask height */
		private var _maskHeightMin:Number;
		
		/** Currently targeted mask height */
		private var _maskHeightTarget:Number;
		
		/** Timer for updating mask size */
		private var _maskTimer:Timer;
		
		/** Remember megazine for page navigation calls */
		private var _mz:MegaZine;
		
		/** The normal buttons - used for toggling some of them */
		private var _navButtons:Array; // Array // SimpleButton
		
		/** Currently highlighted button */
		private var _pageButtonActive:SimpleButton;
		
		/** The pagination buttons - used for updating the highlight */
		private var _pageButtons:Array; // SimpleButton
		
		/** The page number display for the left page */
		private var _pageNumLeft:PageNumber;
		
		/** The page number display for the right page */
		private var _pageNumRight:PageNumber;
		
		/** Thumbnail container */
		private var _pageThumb:DisplayObjectContainer;
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Create a new navigation element to display below the pages.
		 * @param	pages
		 * @param	width
		 * @param	thumbWidth
		 * @param	thumbHeight
		 * @param	buttonShow
		 * @param	pageNumbers
		 * @param	currentPage
		 * @param	mz
		 * @param	lib
		 */
		public function Navigation(pages:uint, width:Number, thumbWidth:uint, thumbHeight:uint,
								   buttonShow:Array, pageNumbers:Boolean, pageButtons:Boolean,
								   navigation:Boolean, currentPage:uint, isAbovePages:Boolean,
								   offset:int, mz:MegaZine, loc:Localizer, lib:Library)
		{
			
			// Remember the owning MegaZine object
			this._mz = mz;
			
			// Easy things first: set up the page number display
			if (pageNumbers) {
				try {
					_pageNumLeft = new PageNumber(pages, lib);
					_pageNumRight = new PageNumber(pages, lib);
					_pageNumRight.x = width - _pageNumRight.width;
					currentPage += currentPage & 1;
					_pageNumLeft.setNumber(currentPage);
					_pageNumRight.setNumber(currentPage + 1);
					addChild(_pageNumLeft);
					addChild(_pageNumRight);
				} catch (e:Error) {
					Logger.log("Navigation", "Failed setting up page numbers: " + e.toString(),
							   Logger.TYPE_WARNING);
				}
			}
			
			// Now the more complex stuff, setting up the actual navigational part
			if (navigation) {
				// Create glow filter for active page button
				_glow = new GlowFilter(0xFFFFFF, 1.0, 5.0, 5.0, 3, BitmapFilterQuality.MEDIUM);
				
				// Maximum width
				var maxWidth:uint = width - SPACING * 2;
				if (_pageNumLeft) {
					maxWidth -= _pageNumLeft.width;
				}
				if (_pageNumRight) {
					maxWidth -= _pageNumRight.width;
				}
				
				// Halve the page count (because we only one button for every second page)
				pages = (pages >> 1) + 1;
				
				// How many buttons we will have to fit into the pagination and determine
				// how many buttons are to the left and right of the page buttons
				var btnCount:int = 0;
				var btnsLeft:int = 0;
				
				// This should _definitely_ not happen
				if (buttonShow == null) {
					throw new Error("Invalid buttonShow variable given.");
				}
				
				// Iterators... stupid actionscript needs to learn stupid scoping.
				var i:int;
				var d:DisplayObject;
				
				_buttons = new Sprite();
				_buttons.x = offsetX;
				
				// Create the buttons, first the menu buttons
				// FS,MU,SS,FP - LP,SE,LN
				_navButtons = new Array(
						[lib.getInstanceOf(LibraryConstants.BUTTON_FULLSCREEN) as SimpleButton,
						 lib.getInstanceOf(LibraryConstants.BUTTON_RESTORE) as SimpleButton],
						[lib.getInstanceOf(LibraryConstants.BUTTON_PAGE_LAST) as SimpleButton],
						[lib.getInstanceOf(LibraryConstants.BUTTON_MUTE) as SimpleButton,
						 lib.getInstanceOf(LibraryConstants.BUTTON_UNMUTE) as SimpleButton],
						[lib.getInstanceOf(LibraryConstants.BUTTON_PLAY) as SimpleButton,
						 lib.getInstanceOf(LibraryConstants.BUTTON_PAUSE) as SimpleButton],
						[lib.getInstanceOf(LibraryConstants.BUTTON_HELP) as SimpleButton],
						[lib.getInstanceOf(LibraryConstants.BUTTON_SETTINGS) as SimpleButton],
						[lib.getInstanceOf(LibraryConstants.BUTTON_PAGE_FIRST) as SimpleButton],
						[new LangChooser(loc, lib, isAbovePages)]);
				
				// Register the event listeners for navigation button clicks,
				// to dispatch the actual event. Also create the tooltips.
				var tt:ToolTip, c:int = -1;
				_navButtons[++c][0]["eventType"] = NavigationEvent.FULLSCREEN;
				tt = new ToolTip("", _navButtons[c][0]);
				loc.registerObject(tt, "text", "LNG_FULLSCREEN");
				_navButtons[c][1]["eventType"] = NavigationEvent.RESTORE;
				tt = new ToolTip("", _navButtons[c][1]);
				loc.registerObject(tt, "text", "LNG_RESTORE");
				
				_navButtons[++c][0]["eventType"] = NavigationEvent.PAGE_LAST;
				tt = new ToolTip("", _navButtons[c][0]);
				loc.registerObject(tt, "text", "LNG_LAST_PAGE");
				
				_navButtons[++c][0]["eventType"] = NavigationEvent.MUTE;
				tt = new ToolTip("", _navButtons[c][0]);
				loc.registerObject(tt, "text", "LNG_MUTE");
				_navButtons[c][1]["eventType"] = NavigationEvent.UNMUTE;
				tt = new ToolTip("", _navButtons[c][1]);
				loc.registerObject(tt, "text", "LNG_UNMUTE");
				
				_navButtons[++c][0]["eventType"] = NavigationEvent.PLAY;
				tt = new ToolTip("", _navButtons[c][0]);
				loc.registerObject(tt, "text", "LNG_SLIDESHOW_START");
				_navButtons[c][1]["eventType"] = NavigationEvent.PAUSE;
				tt = new ToolTip("", _navButtons[c][1]);
				loc.registerObject(tt, "text", "LNG_SLIDESHOW_STOP");
				
				_navButtons[++c][0]["eventType"] = NavigationEvent.HELP;
				tt = new ToolTip("", _navButtons[c][0]);
				loc.registerObject(tt, "text", "LNG_HELP");
				
				_navButtons[++c][0]["eventType"] = NavigationEvent.SETTINGS;
				tt = new ToolTip("", _navButtons[c][0]);
				loc.registerObject(tt, "text", "LNG_SETTINGS");
				
				_navButtons[++c][0]["eventType"] = NavigationEvent.PAGE_FIRST;
				tt = new ToolTip("", _navButtons[c][0]);
				loc.registerObject(tt, "text", "LNG_FIRST_PAGE");
				
				
				// Then the page buttons
				_pageButtons = new Array();
				if (pageButtons) {
					for (i = 0; i < pages; i++) {
						_pageButtons.push(
								lib.getInstanceOf(LibraryConstants.BUTTON_PAGE) as SimpleButton);
					}
				}
				
				// Do primary positioning and count which buttons are needed
				for (i = 0; i < buttonShow.length; i++) {
					if (buttonShow[i] && _navButtons[i]) {
						// Increase count and do primary positioning (right ones have to be
						// moved to the right again after we consider how many left buttons
						// there are)
						if ((i & 1) == 0) {
							for each (d in _navButtons[i]) {
								if (d == null) continue;
								d.x = btnsLeft * BUTTON_SIZE;
								d.y = 0;
								// Add event listener
								if (d is SimpleButton) {
									d.addEventListener(MouseEvent.CLICK, onNavButtonClicked);
								} else if (d is LangChooser) {
									d.x += 2;
									d.y = 4;
								}
								// Add to display tree
								_buttons.addChild(d);
							}
							btnsLeft++;
						} else {
							for each (d in _navButtons[i]) {
								if (d == null) continue;
								d.x = offsetX + (btnCount - btnsLeft) * BUTTON_SIZE;
								d.y = 0;
								// Add event listener
								if (d is SimpleButton) {
									d.addEventListener(MouseEvent.CLICK, onNavButtonClicked);
								} else if (d is LangChooser) {
									d.x += 2;
									d.y = 4;
								}
								// Add to display tree
								_buttons.addChild(d);
							}
						}
						btnCount++;
					}
				}
				
				// Calculate some more stuff
				// Width taken by normal buttons
				var buttonPageLeft:Number = BUTTON_SIZE * btnsLeft;
				// Number of page buttons that would fit into a row
				var buttonPagePerRow:int =
							Math.floor((maxWidth - BUTTON_SIZE * btnCount) / BUTTON_PAGE_SIZE);
				// Width taken by page buttons per row
				var buttonPageWidthTotal:Number = pageButtons
												? Math.min(pages, buttonPagePerRow) * BUTTON_PAGE_SIZE
												: 0;
				// Total width of the bar
				var finalWidth:Number = BUTTON_SIZE * btnCount + buttonPageWidthTotal;
				// Number of rows necessary
				var numRows:int = pageButtons ? Math.ceil(pages / buttonPagePerRow) : 1;
				
				// Secondary positioning for right buttons
				for (i = 1; i < _navButtons.length; i += 2) {
					for each (d in _navButtons[i]) {
						if (d == null) continue;
						d.x += BUTTON_SIZE * btnsLeft + buttonPageWidthTotal;
					}
				}
				
				// Create and size the background
				_bg = lib.getInstanceOf(LibraryConstants.BACKGROUND) as DisplayObject;
				_bg.width = finalWidth;
				_bg.height = numRows * BUTTON_SIZE;
				
				// Hide secondary buttons
				for (i = 0; i < _navButtons.length; i++) {
					if (_navButtons[i] == null) continue;
					if (_navButtons[i][1]) {
						_navButtons[i][1].visible = false;
					}
				}
				
				// Restore mute state if necessary
				if (_mz.muted) {
					onSoundsMute(null);
				}
				
				// Add and position the pagination buttons
				for (i = 0; i < _pageButtons.length; i++) {
					
					var button:SimpleButton = _pageButtons[i];
					
					// Create and position
					button.x = buttonPageLeft + (i % buttonPagePerRow) * BUTTON_PAGE_SIZE;
					button.y = Math.floor(Number(i) / Number(buttonPagePerRow)) * BUTTON_SIZE;
					button["page"] = i * 2;
					
					// Add function linkage
					button.addEventListener(MouseEvent.CLICK, onGotoPage);
					button.addEventListener(MouseEvent.ROLL_OVER, onThumbsShow);
					button.addEventListener(MouseEvent.ROLL_OUT, onThumbsHide);
					
					// Tooltip
					var left:int = i * 2;
					var right:int = i * 2 + 1;
					tt = new ToolTip("", button);
					loc.registerObject(tt, "text", "LNG_GOTO_PAGE",
									   [(left > 0 ? left : "")
									    + (left > 0 && right < pages * 2 - 1 ? "/" : "")
										+ (right < pages * 2 - 1 ? right : "")]);
					
					// Add to display
					_buttons.addChild(button);
					
				}
				
				// Thumbnail box setup - not needed if there are no page buttons
				// (no way to display it then)
				if (pageButtons) {
					_pageThumb = new Sprite();
					var thumbBackground:DisplayObject =
									lib.getInstanceOf(LibraryConstants.BACKGROUND) as DisplayObject;
					thumbBackground.width = thumbWidth * 2 + THUMB_BORDER * 2;
					thumbBackground.height = thumbHeight + THUMB_BORDER * 2;
					_pageThumb.x = width * 0.5 - thumbWidth - THUMB_BORDER;
					if (isAbovePages) {
						_pageThumb.y = BUTTON_SIZE + offset + 25;
					} else {
						_pageThumb.y = -thumbHeight - THUMB_BORDER * 2 - offset - 25;
					}
					_pageThumb.addChild(thumbBackground);
					_pageThumb.visible = false;
				}
				
				// Center it all
				var offsetX:uint = (width - finalWidth) * 0.5;
				_bg.x += offsetX;
				_buttons.x += offsetX;
				
				// Add stuff to display tree
				addChild(_bg);
				addChild(_buttons);
				if (pageButtons) {
					addChild(_pageThumb);
				}
				
				// Check if there are multiple rows. If there are, build the extender.
				if (numRows > 1) {
					
					// The min and max heights
					_maskHeightMin = BUTTON_SIZE;
					_maskHeightTarget = BUTTON_SIZE;
					_maskHeightMax = _bg.height;
					
					// Create the mask
					_mask = new Shape();
					_mask.graphics.beginFill(0xFF00FF);
					_mask.graphics.drawRect(0, 0, _bg.width, _maskHeightMin);
					_mask.graphics.endFill();
					_mask.x = _bg.x;
					_buttons.mask = _mask;
					
					// Initialize the timer
					_maskTimer = new Timer(40);
					_maskTimer.addEventListener(TimerEvent.TIMER, updateMask);
					
					// Add event listeners for mouse over and out
					_bg.addEventListener(MouseEvent.ROLL_OVER, fadeIn);
					_bg.addEventListener(MouseEvent.ROLL_OUT, fadeOut);
					_buttons.addEventListener(MouseEvent.ROLL_OVER, fadeIn);
					_buttons.addEventListener(MouseEvent.ROLL_OUT, fadeOut);
					
					// Set background height
					_bg.height = _mask.height;
					
					// Centering and adding
					addChild(_mask);
				}
				
				// Set effect for active page
				if (pageButtons) {
					_pageButtonActive = _pageButtons[currentPage];
					_pageButtonActive.downState.filters = [_glow];
					_pageButtonActive.overState.filters = [_glow];
					_pageButtonActive.upState.filters   = [_glow];
				}
				
				// Register for page change events.
				mz.addEventListener(MegaZineEvent.SLIDE_START, onSlideStart);
				mz.addEventListener(MegaZineEvent.SLIDE_STOP, onSlideStop);
				mz.addEventListener(MegaZineEvent.MUTE, onSoundsMute);
				mz.addEventListener(MegaZineEvent.UNMUTE, onSoundsUnmute);
			}
			
			if (pageNumbers || pageButtons) {
				mz.addEventListener(MegaZineEvent.PAGE_CHANGE, onPageChange);
			}
			
			addEventListener(Event.ADDED_TO_STAGE, registerEventListeners);
		}
		
		private function registerEventListeners(e:Event):void {
			// Only once
			removeEventListener(Event.ADDED_TO_STAGE, registerEventListeners);
			// Toggling fullscreen buttons
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
			// When removed from stage remove listeners
			addEventListener(Event.REMOVED_FROM_STAGE, removeEventListeners);
		}
		
		private function removeEventListeners(e:Event):void {
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
			_mz.removeEventListener(MegaZineEvent.PAGE_CHANGE, onPageChange);
			_mz.removeEventListener(MegaZineEvent.SLIDE_START, onSlideStart);
			_mz.removeEventListener(MegaZineEvent.SLIDE_START, onSlideStop);
			_mz.removeEventListener(MegaZineEvent.MUTE, onSoundsMute);
			_mz.removeEventListener(MegaZineEvent.UNMUTE, onSoundsUnmute);
		}
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		// ----------------------------------------------------------------------------------- //
		// Event handling
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Toggle fullscreen button.
		 * @param e used to determine which button to show.
		 */
		private function onFullscreen(e:FullScreenEvent):void {
			_navButtons[0][0].visible = !e.fullScreen;
			_navButtons[0][1].visible = e.fullScreen;
		}
		
		/**
		 * Trigger navigating to a page. Which page is read from the button firing the event.
		 * @param e used to get the page number.
		 */
		private function onGotoPage(e:MouseEvent):void {
			var page:uint = e.target["page"];
			dispatchEvent(new NavigationEvent(NavigationEvent.GOTO_PAGE, page));
		}
		
		/**
		 * Fire event when button in the menu was clicked.
		 * @param e used to determine which button was clicked.
		 */
		private function onNavButtonClicked(e:MouseEvent):void {
			var type:String = e.target["eventType"];
			dispatchEvent(new NavigationEvent(type));
		}
		
		/**
		 * Update page nubmer display
		 * @param e the page change event.
		 */
		private function onPageChange(e:MegaZineEvent):void {
			// Update page numbers if existant
			var page:uint = e.page + (e.page & 1);
			if (_pageNumLeft) {
				_pageNumLeft.setNumber(page);
			}
			if (_pageNumRight) {
				_pageNumRight.setNumber(page + 1);
			}
			
			// Update highlight of page navigation
			if (_pageButtons != null) {
				page = e.page >> 1;
				if (_pageButtonActive) {
					_pageButtonActive.downState.filters = null;
					_pageButtonActive.overState.filters = null;
					_pageButtonActive.upState.filters   = null;
				}
				_pageButtonActive = _pageButtons[page];
				_pageButtonActive.downState.filters = [_glow];
				_pageButtonActive.overState.filters = [_glow];
				_pageButtonActive.upState.filters   = [_glow];
			}
		}
		
		/**
		 * Toggle slideshow controls.
		 * @param e unused.
		 */
		private function onSlideStart(e:MegaZineEvent):void {
			_navButtons[3][0].visible = false;
			_navButtons[3][1].visible = true;
		}
		
		/**
		 * Toggle slideshow controls.
		 * @param e unused.
		 */
		private function onSlideStop(e:MegaZineEvent):void {
			_navButtons[3][0].visible = true;
			_navButtons[3][1].visible = false;
		}
		
		/**
		 * Toggle mute controls.
		 * @param e unused.
		 */
		private function onSoundsMute(e:MegaZineEvent):void {
			_navButtons[2][0].visible = false;
			_navButtons[2][1].visible = true;
		}
		
		/**
		 * Toggle mute controls.
		 * @param e unused.
		 */
		private function onSoundsUnmute(e:MegaZineEvent):void {
			_navButtons[2][0].visible = true;
			_navButtons[2][1].visible = false;
		}
		
		/**
		 * Hide currently displayed thumbnail and the container.
		 * @param e unused.
		 */
		private function onThumbsHide(e:MouseEvent):void {
			_pageThumb.visible = false;
			// The removal is important!
			// a) So that there are not all thumbnails of all pages in there in the end
			// b) If the thumbs have no parent they are not rerendered, saving a lot cpu time
			while (_pageThumb.numChildren > 1) {
				_pageThumb.removeChildAt(1);
			}
		}
		
		/**
		 * Show thumbnails, based on the page number stored in the button firing the event.
		 * @param e used to get the page number.
		 */
		private function onThumbsShow(e:MouseEvent):void {
			var page:uint = e.target["page"];
			var thumbs:Array = _mz.getThumbnailsFor(page);
			// Test for left thumbnail
			if (thumbs[0] != null) {
				thumbs[0].x = 10;
				thumbs[0].y = 10;
				_pageThumb.addChild(thumbs[0]);
			}
			// Test for right thumbnail
			if (thumbs[1] != null) {
				thumbs[1].x = thumbs[1].width + 10;
				thumbs[1].y = 10;
				_pageThumb.addChild(thumbs[1]);
			}
			_pageThumb.visible = true;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Fader
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Begin fading in additional button rows
		 * @param e unused.
		 */
		private function fadeIn(e:MouseEvent):void {
			_maskHeightTarget = _maskHeightMax;
			_maskTimer.start();
		}
		
		/**
		 * Begin fading out additional button rows
		 * @param e unused.
		 */
		private function fadeOut(e:MouseEvent):void {
			_maskHeightTarget = _maskHeightMin;
			_maskTimer.start();
		}
		
		/**
		 * Update the mask size (and background size)
		 * @param e unused.
		 */
		private function updateMask(e:TimerEvent):void {
			// Buffer height to top, for language buttons
			_mask.height = Math.max(0, _mask.height - 150);
			_mask.y = 0;
			
			// Interpolate closer to the target height.
			_mask.height += (_maskHeightTarget - _mask.height) * 0.5;
			
			// Stop running when the target is almost reached.
			if (Math.abs(_mask.height - _maskHeightTarget) < 1) {
				_mask.height = _maskHeightTarget;
				_maskTimer.stop();
			}
			
			_bg.height = _mask.height;
			
			// Buffer height to top, for language buttons
			_mask.height += 150;
			_mask.y = -150;
		}
		
	}
	
}