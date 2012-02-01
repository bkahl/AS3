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
	
	import de.mightypirates.megazine.events.MegaZineEvent;
	import de.mightypirates.megazine.gui.Cursor;
	import de.mightypirates.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.*;
	
	/**
	 * The DragHandler class is responsible for handling user mouse input triggering page
	 * dragging or turning, and for making pages turn. It also handles api calls triggering
	 * page turns. This class makes sure only a certain number of pages can be turned at a
	 * time, that the direction cannot be reversed while turning, plays back the page sounds
	 * (e.g. when starting to drag manually) and sets the displayed cursor when dragging.
	 * It updates the position where a currently dragged page should be dragged to (the
	 * cursor position).
	 * Actual page turn animation is handled by the Page objects.
	 * 
	 * @author fnuecke
	 */
	internal class DragHandler extends EventDispatcher {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/** Cursor near any edge */
		private static const CURSOR_NOWHERE:int         = 0; // 0000
		
		/** Cursor is near the left edge */
		private static const CURSOR_LEFT:int            = 1; // 0001
		
		/** Cursor is near the right edge */
		private static const CURSOR_RIGHT:int           = 2; // 0010
		
		/** Cursor is near the top edge */
		private static const CURSOR_TOP:int             = 4; // 0100
		
		/** Cursor is near the bottom edge */
		private static const CURSOR_BOTTOM:int          = 8; // 1000
		
		
		/** Sound when starting to drag manually */
		private static const SOUND_DRAG:uint            = 0;
		
		/** Sound when restoring a page after dragging */
		private static const SOUND_RESTORE:uint         = 1;
		
		/** Sound when completing a page turn */
		private static const SOUND_TURN:uint            = 2;
		
		/** Sound when starting to drag a stiff page */
		private static const SOUND_DRAGSTIFF:uint       = 3;
		
		/** Sound when finishing the pageturn of a stiff page */
		private static const SOUND_ENDSTIFF:uint        = 4;
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Set to true while flipping over multiple _pages, disabling interactivity with the
		 * _pages during that time.
		 */
		private var _autoTurning:Boolean = false;
		
		/** Cursor not on _stage */
		private var _curOut:int = 0;
		
		/** Current main page */
		private var _currentPage:uint;
		
		/** Temporarily disable userinteraction, e.g. when settings or help is open */
		private var _disabled:Boolean;
		
		/** The page currently being dragged */
		private var _draggedPage:Page;
		
		/**
		 * This distance will be kept from a corner / edge that is manually dragged from
		 * its initial edge (e.g. left edge if it's a left corner), to avoid faster-than-ok
		 * movements
		 */
		private var _dragKeepDistance:uint;
		
		/**
		 * If the cursor gets closer than this to a corner the automatic drag is started;
		 * also, this is the range in which clicks initialize page turns
		 */
		private var _dragRange:uint;
		
		/** Defines how fast _pages move; the higher the faster */
		private var _dragSpeed:Number;
		
		/** The point where the current drag started (to check if it was a click) */
		private var _dragStart:Vector2D;
		
		/** Use hand cursor instead of arrows */
		private var _handCursor:Boolean = false;
		
		/** If more than this number of _pages are turned at once turn them instantly */
		private var _instantJumpCount:uint;
		
		/** Tells if the last drag or page turn was left to right or right to left */
		private var _leftToRight:Boolean = false;
		
		/** The MegaZine object this handler belongs to */
		private var _mz:MegaZine;
		
		/** Array with all pages in the megazine */
		private var _pages:Array; // Page
		
		/**
		 * Holds all even pages, needed for fast depth changes when the
		 * page turn direction changes.
		 */
		private var _pagesEven:DisplayObjectContainer;
		
		/**2
		 * Holds all odd pages, needed for fast depth changes when the
		 * page turn direction changes.
		 */
		private var _pagesOdd:DisplayObjectContainer;
		
		/** Page turning/dragging/restoring sounds */
		private var _pageSounds:Array; // Array // Sound
		
		/** Number of _pages that can be skipped before quality is reduced */
		private var _pagesToLowQuality:uint;
		
		/** Total number of pages */
		private var _pagesTotal:uint;
		
		/** Pages currently animated - for quality control */
		private var _pagesTurning:int = 0;
		
		/** The page currently being restored */
		private var _restoringPage:Page;
		
		/**
		 * Number of different sound types currently being loaded.
		 * Used to determine when loading is completed.
		 */
		private var _soundsLoading:uint;
		
		/** The last stage object the owning megazine was on (for listeners) */
		private var _stage:Stage;
		
		/** Currently targeted page when turning _pages */
		private var _targetPage:int = 0;
		
		/** Use page turn sounds */
		private var _usePageTurnSounds:Boolean  = true;
		
		/**
		 * Indicates if we can do the next pageturn already, and if not how many more
		 * calculations (redrawTimed) we have to wait.
		 */
		private var _waitNextTurn:uint = 0;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new drag handler for a megazine, handling user mouse interaction and page
		 * turning triggered via the gotoPage method.
		 * @param _mz The MegaZine the handler should belong to.
		 */
		public function DragHandler(_mz:MegaZine) {
			
			this._mz = _mz;
			_stage = _mz.stage;
			
			_dragStart = new Vector2D();
			
		}
		
		// ----------------------------------------------------------------------------------- //
		// Setter
		// ----------------------------------------------------------------------------------- //
		
		/** User interaction via mouse disabled or not */
		public function set disabled(setTo:Boolean):void {
			_disabled = setTo;
		}
		
		// ----------------------------------------------------------------------------------- //
		// Secondary initialization
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Sets variables gotten from the gui.
		 * @param _curTurnLeft The cursor image used when turning left to right.
		 * @param _curTurnRight The cursor image used when turning right to left.
		 */
		//internal function setGUI(curTurnLeft:DisplayObject, curTurnRight:DisplayObject):void {
		//	_curTurnLeft = curTurnLeft;
		//	_curTurnRight = curTurnRight;
		//}
		
		/**
		 * Set page information of the initialized _pages.
		 * @param pages The array with all pages in the megazine.
		 * @param pagesOdd The array of the even pages.
		 * @param pagesEven The array of the odd pages.
		 * @param currentPage The current page.
		 */
		internal function setPages(pages:Array, pagesOdd:DisplayObjectContainer,
								   pagesEven:DisplayObjectContainer, currentPage:uint):void
		{
			_pages = pages;
			_pagesEven = pagesEven;
			_pagesOdd = pagesOdd;
			_pagesTotal = _pages.length;
			// Page turn complete handlers
			for (var i:uint = 0; i < _pages.length; i += 2) {
				(_pages[i] as Page).addEventListener(MegaZineEvent.STATUS_CHANGE, turnComplete);
			}
			
			// Update the depths
			updateDepths();
			// And visibility
			updateVisibility();
			
			// This one is called last, so register the listeners now.
			registerListeners();
			
			// Only use the listeners while megazine is on the _stage
			_mz.addEventListener(Event.ADDED_TO_STAGE, registerListeners);
			_mz.addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			
			// Muting / unmuting
			_mz.addEventListener(MegaZineEvent.MUTE, mute);
			_mz.addEventListener(MegaZineEvent.UNMUTE, unmute);
			
			// Go to initial page (without sound, though)
			mute();
			gotoPage(currentPage, true);
			if (!_mz.muted) unmute();
		}
		
		/**
		 * Sets variables read from the xml configuration.
		 * @param handCursor Use a hand cursor instead of images when hovering draggable area.
		 * @param usePageTurnSounds Activate sounds when dragging/turning _pages.
		 * @param dragKeepDistance Distance to keep from the edge when dragging
		 * @param dragRange Area in which autodragging / clickturning is possible.
		 * @param dragSpeed Animation speed for dragging and turning.
		 * @param pagesToLowQuality Count of _pages that can be turned before switching
		 * to low quality.
		 * @param instantJumpCount Number of _pages that may be turned with the gotoPage
		 * method before instant turning is used.
		 */
		internal function setXMLVars(handCursor:Boolean, usePageTurnSounds:Boolean,
									 dragKeepDistance:Number, dragRange:Number, dragSpeed:Number,
									 pagesToLowQuality:uint, instantJumpCount:uint):void
		{
			_handCursor        = handCursor;
			_usePageTurnSounds = usePageTurnSounds;
			_dragKeepDistance  = dragKeepDistance;
			_dragRange         = dragRange;
			_dragSpeed         = dragSpeed;
			_pagesToLowQuality = pagesToLowQuality;
			_instantJumpCount  = instantJumpCount;
			
			// Begin loading the sounds in the background.
			if (_usePageTurnSounds) {
				_pageSounds = new Array(new Array(),   // drag
										new Array(),   // restore
										new Array(),   // turn
										new Array(),   // dragstiff
										new Array());  // endstiff
				
				_soundsLoading = 5;
				loadSound(SOUND_DRAGSTIFF);
				loadSound(SOUND_ENDSTIFF);
				loadSound(SOUND_DRAG);
				loadSound(SOUND_RESTORE);
				loadSound(SOUND_TURN);
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Listener handling
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Register listeners for mouse events.
		 * @param	e
		 */
		private function registerListeners(e:Event = null):void {
			
			_stage = _mz.stage;
			
			// Mouse event listener
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			// Mouse leaves the _stage
			_stage.addEventListener(Event.MOUSE_LEAVE, mouseLeave);
			_stage.addEventListener(Event.ENTER_FRAME, update);
			
		}
		
		/**
		 * Remove listeners for mouse events.
		 * @param	e
		 */
		private function removeListeners(e:Event = null):void {
			
			// Mouse event listener
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			// Mouse leaves the _stage
			_stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeave);
			_stage.removeEventListener(Event.ENTER_FRAME, update);
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Input event handlers for mouse
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Handle mouse downs
		 * @param e The event data
		 */
		private function mouseDown(e:MouseEvent):void {
			
			// Disable all interactivity with the _pages during autoturning
			if (_autoTurning || !_pagesOdd.visible || !_pagesEven.visible || _disabled) {
				return;
			}
			
			if (!_draggedPage) {
				
				// No dragging yet, try to begin edge dragging
				beginDrag(getCursorPosition());
				
			} else if (_draggedPage.state != Page.READY &&
					 _draggedPage.state != Page.DRAGGING)
			{
				return;
			}
			
			if (_draggedPage) {
				_draggedPage.beginUserDrag();
				
				// Play sound
				playSoundOfType(_draggedPage.isStiff ? SOUND_DRAGSTIFF : SOUND_DRAG);
			}
			_dragStart.setTo(_mz.mouseX, _mz.mouseY);
			
		}
		
		/**
		 * Handle the mouse leaving the _stage. If autodragging cancel the drag. Note that
		 * a mousemove event is fired after the mouse leave event, so we have to remember
		 * that we left, to avoid the autodrag being reinitiated.
		 * @param e The event data
		 */
		private function mouseLeave(e:Event):void {
			// Remember that the cursor left the _stage
			_curOut = 1;
			if (_draggedPage == null || _draggedPage.state != Page.DRAGGING_USER) {
				Cursor.cursor = Cursor.DEFAULT;
				Cursor.visible = true;
				cancelDrag();
			}
		}
		
		/**
		 * Handle mousemovements, these can trigger an automatic drag if near corners and
		 * update the position of the drag target if a page is dragged.
		 * @param e The event data
		 */
		private function mouseMove(e:MouseEvent = null):void {
			
			// This is to fix the problem with the mouse move event being fired once even
			// after the mouse leave event was fired.
			if (_curOut > 0) {
				_curOut--;
				return;
			}
			
			// Disable all interactivity with the _pages during autoturning
			if (_autoTurning || !_pagesOdd.visible || !_pagesEven.visible || _disabled) {
				return;
			}
			
			var curPos:int = getCursorPosition();
			var inCorner:Boolean = (curPos & (CURSOR_LEFT | CURSOR_RIGHT)) > 0 &&
								   (curPos & (CURSOR_TOP | CURSOR_BOTTOM)) > 0;
			
			// Check if the page is being dragged. If not, check if cursor is in a corner.
			if (_draggedPage != null && (_draggedPage.state == Page.DRAGGING ||
										_draggedPage.state == Page.DRAGGING_USER))
			{
				if (inCorner || _draggedPage.state == Page.DRAGGING_USER) {
					// Manually dragging or in range, update target
					_draggedPage.setDragTarget(new Vector2D(_mz.mouseX, _mz.mouseY));
				} else {
					// Dragging automatically but not near a corner: cancel the drag
					cancelDrag();
				}
			} else if (inCorner) {
				// OK, it's a corner, begin dragging (only for non stiff pages, though).
				var p:Page = _pages[(curPos & CURSOR_LEFT) ? _currentPage - 1 : _currentPage];
				if (p != null && !p.isStiff) {
					beginDrag(curPos);
				}
			}
			
			// Update cursor visibility / type
			if (_pagesOdd.visible && _pagesEven.visible) {
				if (_pages[_currentPage - 1] && (curPos & CURSOR_LEFT)) {
					if (_handCursor) {
						_mz.buttonMode = true;
					}
					if (Cursor.cursor != Cursor.TURN_LEFT
						&& Cursor.cursor != Cursor.TURN_RIGHT) {
						Cursor.cursor = Cursor.TURN_LEFT;
					}
				} else if (_pages[_currentPage] && (curPos & CURSOR_RIGHT)) {
					if (_handCursor) {
						_mz.buttonMode = true;
					}
					if (Cursor.cursor != Cursor.TURN_LEFT
						&& Cursor.cursor != Cursor.TURN_RIGHT) {
						Cursor.cursor = Cursor.TURN_RIGHT;
					}
				} else if (!_draggedPage) {
					if (_handCursor) {
						_mz.buttonMode = false;
					}
					if (Cursor.cursor == Cursor.TURN_LEFT
						|| Cursor.cursor == Cursor.TURN_RIGHT)
					{
						Cursor.cursor = Cursor.DEFAULT;
					}
				}
			}
			
		}
		
		/**
		 * Handle mouse releases
		 * @param e The event data
		 */
		private function mouseUp(e:MouseEvent):void {
			
			// Update cursor image visibility
			Cursor.cursor = Cursor.DEFAULT;
			
			// Disable all interactivity with the _pages during autoturning
			if (_autoTurning || !_pagesOdd.visible || !_pagesEven.visible || _disabled) {
				return;
			}
			
			if (_draggedPage && (_draggedPage.state == Page.DRAGGING ||
								_draggedPage.state == Page.DRAGGING_USER))
			{
				
				// Conditions for a completed pageturn are the cursor being in range of the
				// point where it started (click), or far enough away (_mz.getPageWidth()).
				var dist:Number = _dragStart.distance(new Vector2D(_mz.mouseX,
																  _mz.mouseY));
				if (dist < _dragRange || dist > _mz.pageWidth) {
					
					// Complete the turn
					if (turnPage(_leftToRight)
						&& !_pages[_leftToRight ? _currentPage : _currentPage - 1].isStiff)
					{
						playSoundOfType(SOUND_TURN);
					}
					
				} else {
					
					// Cancel the drag and return to the old position
					cancelDrag();
					
				}
				
			}
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Dragging and turning _pages
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Start dragging a page.
		 * @param fromPosition The area from where to start defined via the CURSOR_ constants
		 */
		private function beginDrag(fromPosition:int):void {
			
			// If _waitNextTurn > 0 we don't do anything
			if (_waitNextTurn) {
				return;
			}
			
			// Check which way to turn
			var leftToRight:Boolean = Boolean(fromPosition & CURSOR_LEFT);
			
			// Check if the rightToLeft is valid, else cancel
			if (!leftToRight && !(fromPosition & CURSOR_RIGHT)) {
				return;
			}
			
			// Get the page we need to drag
			_draggedPage = _pages[leftToRight ? _currentPage - 2 : _currentPage];
			
			// If the _draggedPage is null cancel (the page does not exist)
			if (!_draggedPage) {
				return;
			}
			
			// Check if the page can be dragged
			if (_draggedPage.state == Page.READY) {
				
				// OK, get the dragging offset
				var dragOffset:Number = 0;
				if (fromPosition & (CURSOR_BOTTOM | CURSOR_TOP)) {
					
					// It's close to the top or bottom, so make it a corner drag
					dragOffset = fromPosition & CURSOR_BOTTOM ? _mz.pageHeight : 0;
					
				} else {
					
					// Somewhere inbetween, make it an edge drag
					dragOffset = _mz.mouseY;
					
				}
				
				_leftToRight = leftToRight;
				
				// And begin the drag
				_draggedPage.beginDrag(new Vector2D(_mz.mouseX, _mz.mouseY),
									  dragOffset, _leftToRight);
				
				// And update the page order
				updateDepths();
				
				// Update page visibility (make _pages dragging towards visible)
				try {
					var current:uint = _currentPage;
					if (_leftToRight) {
						current -= 2;
						(_pages[current] as Page).pageEven.visible = true;
						(_pages[current - 2] as Page).pageOdd.visible = true;
						while (((_pages[current - 2] as Page).getBackgroundColor(false) >>> 24)
								< 255)
						{
							current -= 2;
							(_pages[current - 2] as Page).pageOdd.visible = true;
						}
					} else {
						current += 2;
						(_pages[current - 2] as Page).pageOdd.visible = true;
						(_pages[current] as Page).pageEven.visible = true;
						while (((_pages[current] as Page).getBackgroundColor(true) >>> 24)
								< 255)
						{
							current += 2;
							(_pages[current] as Page).pageEven.visible = true;
						}
					}
				} catch (e:Error) { /* _pages[X] invalid */ }
				
			} else {
				
				// Page cannot be dragged... so forget about it
				_draggedPage = null;
				
			}
			
		}
		
		/**
		 * Cancel the current page turning returning it to its previous state.
		 * @param instant Instantly reset the dragged page
		 */
		private function cancelDrag(instant:Boolean = false):void {
			
			// Check if we're actually dragging a page
			if (_draggedPage && (_draggedPage.state == Page.DRAGGING ||
								_draggedPage.state == Page.DRAGGING_USER))
			{
				
				// Play sound if user drag.
				if (_draggedPage.state == Page.DRAGGING_USER && !_draggedPage.isStiff) {
					playSoundOfType(SOUND_RESTORE);
				}
				// Cancel the drag, then forget about the page
				if (!instant) {
					_restoringPage = _draggedPage;
				}
				_draggedPage.cancelDrag(instant);
				_draggedPage = null;
				
			}
			
		}
		
		/**
		 * Check if the cursor is near any edges, and if yes which
		 * @return A combination of the cursor position constants
		 */
		private function getCursorPosition():int {
			var ret:int = CURSOR_NOWHERE;
			
			// Check if the cursor is over the _pages at all
			if (_mz.mouseX > 0 && _mz.mouseX < _mz.pageWidth * 2 &&
				_mz.mouseY > 0 && _mz.mouseY < _mz.pageHeight)
			{
				
				// Top of bottom
				if (_mz.mouseY < _dragRange) {
					// Top
					ret |= CURSOR_TOP;
				} else if (_mz.mouseY > _mz.pageHeight - _dragRange) {
					// Bottom
					ret |= CURSOR_BOTTOM;
				}
				
				// Left or right
				if (_mz.mouseX < _dragRange) {
					// Left
					ret |= CURSOR_LEFT;
				} else if (_mz.mouseX > _mz.pageWidth * 2 - _dragRange) {
					// Right
					ret |= CURSOR_RIGHT;
				}
				
			}
			
			return ret;
		}
		
		/**
		 * Go to the page with the specified number. If the number does not exist the method
		 * call is ignored. Numeration begins with zero.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param page The number of the page to go to
		 * @param instant No animation, but instant setting
		 */
		public function gotoPage(page:int, instant:Boolean = false):void {
			
			// Disable all interactivity with the _pages during autoturning, also don't turn
			// if dragging manually.
			if (_autoTurning
				|| (_draggedPage && (_draggedPage.state == Page.DRAGGING_USER))
				|| (_pagesTurning > 0 && page < _currentPage != _leftToRight))
			{
				return;
			}
			
			
			// Check if the page is valid, i.e. if it exists, and if we're not already there.
			if (page >= 0 && page <= _pagesTotal &&
				page != _currentPage - 1 && page != _currentPage)
			{
				
				// Make it an even page number
				page += page & 1;
				
				// Check if we're currently dragging a page, and if yes, if it's in the same
				// direction. If not, cancel the drag first.
				if (_draggedPage && 
					int(page < _currentPage) ^ int(_draggedPage.getNumber(true) < _currentPage))
				{
					// Instantly (depths cant be right when dragging in both directions at once).
					cancelDrag(true);
				}
				
				// How many _pages have to be turned?
				var count:int = _currentPage - page;
				count = (count < 0 ? -count : count) >>> 1;
				
				// Trigger the page turn in the proper direction, with the necessary amount
				// of turns, and a delay that is directly inversely proportional to the
				// number of _pages turned, so that the total time needed stays constant.
				if (turnPage(page < _currentPage ? true : false, count,
							 instant ? 0 : 500 / count))
				{
					// Play sound
					try {
						playSoundOfType(_pages[_leftToRight
												? _currentPage
												: _currentPage - 1].isStiff
										? SOUND_DRAGSTIFF
										: SOUND_TURN);
					} catch (e:Error) { }
				}
				
			}
			
		}
		
		/**
		 * Updates visibility after a page movement is complete by hiding the old _pages.
		 * If one of it (which on depends on the turning direction of course) is still visible
		 * due to the new page's invisibility do not hide it, though.
		 * Also reduce count of pages currently turning and adjust movie quality accordingly.
		 * @param e Event data
		 */
		private function turnComplete(e:MegaZineEvent):void {
			if (e.state != Page.READY) {
				return;
			}
			
			try {
				var current:uint = e.page;
				// Depending on where we were turning, and whether we were restoring
				// or completed a turn update visibility.
				if (int(e.leftToRight) ^ int(e.prevstate == Page.RESTORING)) {
					(_pages[e.page] as Page).pageOdd.visible = false;
					if (((_pages[e.page] as Page).getBackgroundColor(true) >>> 24) == 255) {
						// Opaque, make all following visible pages invisible
						while ((_pages[current + 2] as Page).pageEven.visible) {
							current += 2;
							(_pages[current] as Page).pageEven.visible = false;
						}
					}
				} else {
					(_pages[e.page] as Page).pageEven.visible = false;
					if (((_pages[e.page] as Page).getBackgroundColor(false) >>> 24) == 255) {
						// Opaque, make all following visible _pages invisible
						while ((_pages[current - 2] as Page).pageOdd.visible) {
							current -= 2;
							(_pages[current] as Page).pageOdd.visible = false;
						}
					}
				}
			} catch (e:Error) { /* invalid page */ }
			
			// Only when a turn was complete
			if (e.prevstate == Page.TURNING) {
				// Reduce count of _pages currently moving, and update the quality if needed.
				_pagesTurning = _pagesTurning < 2 ? 0 : _pagesTurning - 1;
				if (_pagesTurning > _pagesToLowQuality) {
					_stage.quality = StageQuality.LOW;
				} else if (_pagesTurning > 0) {
					_stage.quality = StageQuality.MEDIUM;
				} else {
					_stage.quality = StageQuality.HIGH;
				}
				
				// Play sound if it was a stiff page.
				if ((e.target as Page).isStiff) {
					playSoundOfType(SOUND_ENDSTIFF);
				}
				
				if (_draggedPage == null) {
					// Needs delayed execution to avoid graphical glitches
					// (highlights not getting cleared, which is actually pretty weird)
					setTimeout(mouseMove, 100);
				}
			}
			
		}
		
		/**
		 * Turn the currently dragged page around completely, or turn the current _pages in the
		 * direction specified. If a page is currently dragged it is assumed that that page
		 * sould be turned and all arguments are ignored.
		 * @param leftToRight Only used if not currently dragging a page. When used specifies in
		 * which direction to turn.
		 * @param count How many pages to turn
		 * @param delay The delay in milliseconds between the pages start turning (only used if
		 * count > 1)
		 * @param recursive Tells whether the method was called recursively.
		 * @return true if a page turn was triggered.
		 */
		private function turnPage(leftToRight:Boolean, count:int = 1, delay:uint = 0,
								  recursive:Boolean = false):Boolean
		{
			
			var pageTurned:Page, pageOpposite:Page;
			
			// If _waitNextTurn > 0 we cannot turn yet - but cancel any drag, just to make sure.
			// Overidden by automatic turning...
			if (_waitNextTurn && !_autoTurning) {
				if (_draggedPage) {
					cancelDrag();
				}
				return false;
			}
			
			// Wait until we may do the next pageturn
			_waitNextTurn = 1 / _dragSpeed;
			// Increase the wait time if the current page was a normal one and the next is a
			// stiff page, otherwise graphical glitches occur (well, it looks kinda unrealistic).
			if (leftToRight && (!(_pages[_currentPage - 1] as Page).isStiff
								  && _currentPage - 3 > 0
								  && (_pages[_currentPage - 3] as Page).isStiff)
				|| !leftToRight && (!(_pages[_currentPage] as Page).isStiff
									&& _currentPage + 2 < _pagesTotal
									&& (_pages[_currentPage + 2] as Page).isStiff))
			{
				_waitNextTurn *= 4;
			}
			
			// Currently dragging/moving?
			if (_draggedPage) {
				
				// OK, turn the page and then forget about it
				_pagesTurning++;
				_draggedPage.turnPage();
				_draggedPage = null;
				
			} else if (delay < 1 || count > _instantJumpCount) {
				
				// "Instant" turning (no parallel flipping)
				
				// No need to wait in that case
				_waitNextTurn = 0;
				// Not dragging, check which way to turn, and if the turn is valid
				if (leftToRight && (_pages[_currentPage - count * 2]
									|| _pages[_currentPage - 1 - count * 2]))
				{
					// Valid left to right turn
					_currentPage = _currentPage - count * 2;
				} else if (!leftToRight && (_pages[_currentPage + count * 2]
											|| _pages[_currentPage - 1 + count * 2]))
				{
					// Valid right to left turn
					_currentPage = _currentPage + count * 2;
				} else {
					// Invalid turn, cancel
					return false;
				}
				
				// Fire an event, telling possible listeners of the new current page
				dispatchEvent(new MegaZineEvent(MegaZineEvent.PAGE_CHANGE, _currentPage));
				
				_leftToRight = _leftToRight;
				
				var i:int;
				for (i = _currentPage; i < _pages.length; i += 2) {
					(_pages[i] as Page).turnPage(true, false);
				}
				for (i = _currentPage - 1; i > 0; i -= 2) {
					(_pages[i] as Page).turnPage(true, true);
				}
				
				// Update depths
				updateDepths();
				
				// Update page visibility
				updateVisibility();
				
				// Quality control reset (needed if pages are skipped while some
				// page turning is still in progress).
				_stage.quality = StageQuality.HIGH;
				_pagesTurning = 0;
				
				return true;
				
			} else {
				
				// Not dragging, check which way to turn, and if the turn is valid
				if (leftToRight && _pages[_currentPage - 1]) {
					// Valid left to right turn
					pageTurned = _pages[_currentPage - 1];
					pageOpposite = _pages[_currentPage + 1];
				} else if (!leftToRight && _pages[_currentPage + 1]) {
					// Valid right to left turn
					pageTurned = _pages[_currentPage + 1];
					pageOpposite = _pages[_currentPage - 1];
				} else {
					// Invalid turn, cancel
					return false;
				}
				
				// Check if page is already being turned, an if the opposite page is
				// in the ready state when changing directions (otherwise graphical
				// errors arise).
				if (pageTurned.state != Page.READY
					|| (leftToRight != _leftToRight && pageOpposite
						&& pageOpposite.state != Page.READY)) {
					return false;
				}
				
				_leftToRight = leftToRight;
				
				// Turn the page
				_pagesTurning++;
				pageTurned.turnPage(false, _leftToRight);
				
			}
			
			// Modify the current page counter appropriately
			if (_leftToRight) {
				_currentPage -= 2;
			} else {
				_currentPage += 2;
			}
			
			// Fire an event, telling possible listeners of the new current page
			dispatchEvent(new MegaZineEvent(MegaZineEvent.PAGE_CHANGE, _currentPage));
			
			// Update depths
			updateDepths();
			
			// Update page visibility (make target ones visible)
			try {
				var current:uint = _currentPage;
				if (_leftToRight) {
					(_pages[_currentPage] as Page).pageEven.visible = true;
					(_pages[_currentPage - 2] as Page).pageOdd.visible = true;
					while (((_pages[current - 2] as Page).getBackgroundColor(false) >>> 24)
								< 255)
					{
						current -= 2;
						(_pages[current - 2] as Page).pageOdd.visible = true;
					}
				} else {
					(_pages[_currentPage - 2] as Page).pageOdd.visible = true;
					(_pages[_currentPage] as Page).pageEven.visible = true;
					while (((_pages[current] as Page).getBackgroundColor(true) >>> 24) < 255) {
						current += 2;
						(_pages[current] as Page).pageEven.visible = true;
					}
				}
			} catch (e:Error) { /* _pages[X] invalid */ }
			
			// Reduce _stage quality if turning many _pages
			if (_pagesTurning > _pagesToLowQuality) {
				_stage.quality = StageQuality.LOW;
			} else if (_pagesTurning > 0) {
				_stage.quality = StageQuality.MEDIUM;
			}
			
			// Call a delayed recursive call of this function, until the remaining count is zero.
			if (count > 1) {
				
				_autoTurning = true;
				_leftToRight = this._leftToRight;
				var t:Timer;
				// Increase the wait time if the current page was a normal one and the next is a
				// stiff page, otherwise graphical glitches occur
				// (well, it looks kinda unrealistic).
				if (_leftToRight && (!(_pages[_currentPage] as Page).isStiff
									 && (_pages[_currentPage - 1] as Page).isStiff)
					|| !_leftToRight && (!(_pages[_currentPage - 1] as Page).isStiff
										 && (_pages[_currentPage] as Page).isStiff))
				{
					t = new Timer(Math.max(_stage.frameRate * 4 / _dragSpeed, delay), 1);
				} else {
					t = new Timer(delay, 1);
				}
				
				t.addEventListener(TimerEvent.TIMER,
					function(e:TimerEvent):void {
						if (turnPage(_leftToRight, count - 1, delay, true)) {
							// Play sound
							playSoundOfType((_pages[_leftToRight
														? _currentPage
														: _currentPage - 1] as Page).isStiff
											? SOUND_DRAGSTIFF
											: SOUND_TURN);
						}
					});
				t.start();
				
			} else {
				_autoTurning = false;
			}
			
			return true;
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Updating
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Reduce wait count for next possible page turn each frame.
		 * @param e unused.
		 */
		private function update(e:Event = null):void {
			
			// Reduce the wait count if greater than zero.
			if (_waitNextTurn) {
				_waitNextTurn--;
				if (!_waitNextTurn) {
					mouseMove();
				}
			}
			
		}
		
		/**
		 * Updates the depths of pages. Depends on the direction we're turning.
		 * When turning left to right the even pages must be on top of the odd ones,
		 * else it's vice versa.
		 */
		private function updateDepths():void {
			
			// Depends on where we currently turn. If we turn left, the even _pages need to be
			// on to, else the odd ones have to be.
			if (int(_leftToRight) ^ int(_mz.getChildIndex(_pagesEven) >
									   _mz.getChildIndex(_pagesOdd)))
			{
				_mz.swapChildren(_pagesEven, _pagesOdd);
			}
			
		}
		
		/**
		 * Updates page visibility for all _pages in the book. This means a complete update,
		 * first hiding all _pages, then starting from the current one and making all relevant
		 * one visible again (can be more due to invisible _pages).
		 */
		private function updateVisibility():void {
			
			// First hide all _pages.
			for (var h:int = 0; h < _pages.length; h++) {
				if (_pages[h] != undefined) {
					if ((_pages[h] as Page).pageOdd) {
						(_pages[h] as Page).pageOdd.visible = false;
					}
					if ((_pages[h] as Page).pageEven) {
						(_pages[h] as Page).pageEven.visible = false;
					}
				}
			}
			
			// Then make the required ones visible again, starting at the current page.
			// This is two times nearly the exact same procedure... once forwards,
			// once backwards.
			
			// Even _pages - forwards.
			for (var i:int = _currentPage; i < _pages.length; i += 2) {
				// Test if the current page exists.
				if (_pages[i] != undefined && (_pages[i] as Page).pageEven) {
					// Make it visible.
					(_pages[i] as Page).pageEven.visible = true;
					// Check if it is opaque / covers all _pages behind it.
					if ((((_pages[i] as Page).getBackgroundColor(true) >>> 24) == 255)
						&& (_pages[i] as Page).state == Page.READY)
					{
						// Jup, no more need for making _pages visible.
						break;
					} else if ((_pages[i] as Page).state != Page.READY
						&& (_pages[i] as Page).pageOdd)
					{
						// Page is being dragged, make the backside visible as well.
						(_pages[i] as Page).pageOdd.visible = true;
					}
				}
			}
			
			// Odd _pages - backwards.
			for (var j:int = _currentPage - 1; j > 0; j -= 2) {
				// Test if the current page exists.
				if (_pages[j] != undefined && (_pages[j] as Page).pageOdd) {
					// Make it visible.
					(_pages[j] as Page).pageOdd.visible = true;
					// Check if it is opaque / covers all _pages behind it.
					if ((((_pages[j] as Page).getBackgroundColor(false) >>> 24) >= 255)
						&& (_pages[j] as Page).state == Page.READY)
					{
						// Jup, no more need for making _pages visible.
						break;
					} else if ((_pages[j] as Page).state != Page.READY
						&& (_pages[j] as Page).pageEven)
					{
						// Page is being dragged, make the backside visible as well.
						(_pages[j] as Page).pageEven.visible = true;
					}
				}
			}
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Sounds
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Try loading a sound of the given type.
		 * @param type The sound type (name of the files).
		 * @param num The running number of the sound
		 */
		private function loadSound(type:uint, num:int = 0):void {
			var name:String;
			switch (type) {
				case 0:
					name = "drag";
					break;
				case 1:
					name = "restore";
					break;
				case 2:
					name = "turn";
					break;
				case 3:
					name = "dragstiff";
					break;
				case 4:
					name = "endstiff";
					break;
				default:
					// Invalid type, cancel.
					return;
			}
			
			var s:Sound = new Sound();
			s.addEventListener(Event.COMPLETE,
				function(e:Event):void {
					_pageSounds[type].push(e.target);
					loadSound(type, num + 1);
				});
			s.addEventListener(IOErrorEvent.IO_ERROR,
				function(e:IOErrorEvent):void {
					// Not found, previous one was the last one.
				});
			try {
				s.load(new URLRequest(_mz.getAbsPath("snd/" + name + num + ".mp3")));
			} catch (ex:SecurityError) {
				Logger.log("MegaZine", "Could not load sound because of a security error.",
						   Logger.TYPE_WARNING);
			}
		}
		
		/**
		 * Mute command from the owning megazine, disable page turn sounds.
		 * @param e unused.
		 */
		private function mute(e:MegaZineEvent = null):void {
			// First set page turn sounds
			_usePageTurnSounds = false;
		}
		
		/**
		 * Plays a random sound of the given type.
		 * @param type The type of the required sound, can be "drag", "restore" or "turn"
		 */
		private function playSoundOfType(type:uint):void {
			// Check if sounds are activated.
			if (!_usePageTurnSounds) {
				return;
			}
			
			// OK, check which sound type to play, pick a random one and play it.
			try {
				// Check if there are any sounds of that type...
				if (_pageSounds[type].length > 0) {
					// Get a random id, cast to int and -0.5 to equalize chances
					// (due to the 0<n<1 thingy).
					_pageSounds[type][uint(_pageSounds[type].length*Math.random() - 0.5)].play();
				}
			} catch (ex:Error) {}
		}
		
		/**
		 * Unmute command from the owning megazine, enable page turn sounds.
		 * @param e unused.
		 */
		private function unmute(e:MegaZineEvent = null):void {
			_usePageTurnSounds = _pageSounds != null
		}
		
	}
	
}
