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
	
	import de.mightypirates.megazine.ElementLoader;
	import de.mightypirates.megazine.events.MegaZineEvent;
	import de.mightypirates.utils.LinkedList;
	
	import flash.events.*;
	import flash.utils.*;
	
	/**
	 * The pageloader class loads an unloads pages on request. Basically it just determines
	 * which pages should be in memory and which should not, and accordingly loads or unloads
	 * pages.
	 * Also handles loading of pages to generate a thumbnail for them, either all at once or
	 * at request.
	 * 
	 * @author fnuecke
	 */
	internal class PageLoader {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** When all thumbnails have been loaded once remember that, to avoid unnecessary ifs */
		private var _allThumbsDone:Boolean = false;
		
		/** The current page, start loading this one first */
		private var _currentPage:uint = 0;
		
		private var _elementLoader:ElementLoader;
		
		/** Remember which pages have already been loaded once (thus already have a thumbnail) */
		private var _loadedOnce:Array; // Boolean
		
		/** Prioritize loading of pages in this array, worked lifo (i.e. via Array.pop) */
		private var _loadPreferred:Array;
		
		/** Only load thumbnails when asked to */
		private var _loadSpecifiedOnly:Boolean = false;
		
		/** Currently loading thumbnails */
		private var _loadThumbActive:Boolean = false;
		
		/** Maximim of pages to be kept in memory */
		private var _maxLoaded:uint = 0;
		
		/** Array containing all pages in the book */
		private var _pages:Array; // Page
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new pageloader for an array of pages.
		 * @param mz The megazine this loader belongs to.
		 * @param current The current page.
		 * @param pages An array with all loadable pages.
		 * @param parallel The number pages that may be loaded at a time.
		 * @param cachesize The number of pages that may be kept loaded at a time,
		 * i.e. pages that are kept in memory. Only half that number of pages to
		 * the left and right of the current page are kept in memory, all other
		 * pages are unloaded.
		 */
		public function PageLoader(mz:MegaZine, current:uint, pages:Array,
								   parallel:uint, cachesize:uint, thumbAuto:Boolean)
		{
			
			_currentPage       = current;
			_pages             = pages;
			_maxLoaded         = cachesize;
			_loadSpecifiedOnly = !thumbAuto;
			_loadedOnce        = new Array(pages.length);
			_loadPreferred     = new Array();
			_elementLoader     = new ElementLoader(parallel);
			
			// Register for page change events if there is a chance that pages need to be
			// reloaded / unloaded.
			mz.addEventListener(MegaZineEvent.PAGE_CHANGE, handlePageChange);
			
			// 0 means load all pages at once, also increase number if it is greater or equal
			// to the page count, so that all pages stay loaded when at a cover of the book.
			if (_maxLoaded == 0 || _maxLoaded >= _pages.length) {
				// Just take an absurdly high number to keep all pages loaded. Times two should
				// be enough, but rounding errors might occur, so to be on the safe side...
				_maxLoaded = _pages.length * 4;
				// All will be loaded anyway, so only load the ones currently requested thumbnails.
				_loadSpecifiedOnly = true;
			}
			
			// Rebuild the complete queue.
			rebuildQueue();
			
			// Initialize the production of thumbnails. This will load one page at a time, until
			// all pages have been loaded once.
			if (_maxLoaded < _pages.length && !_loadSpecifiedOnly) {
				makeThumbs();
			}
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Sets the page for which to generate the thumbnails next - this does not mean that
		 * the thumbnail is generated instantly, just that the next thumbnail that will be
		 * generated will be that of the given page.
		 * @param page The page for which to generate the thumbnail.
		 */
		internal function prioritizeThumbForPage(page:uint):void {
			// If everything is done already ignore the command.
			if (_allThumbsDone) {
				return;
			}
			// Clear the request queue if only loading specified.
			if (_loadSpecifiedOnly) {
				_loadPreferred = new Array();
			}
			// Add the page and its right neighbour to the request queue if they have not
			// been loaded once before.
			if (_loadedOnce.length > page + 1 && !_loadedOnce[page + 1]) {
				_loadPreferred.push(page + 1);
			}
			if (_loadedOnce.length > page && !_loadedOnce[page]) {
				_loadPreferred.push(page);
			}
			// Start loading if not active and there is something to load.
			if (_loadPreferred.length > 0 && !_loadThumbActive) {
				makeThumbs();
			}
		}
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * When the page changes in the megazine update the loaded pages.
		 * @param e used to retrieve the new current page.
		 */
		private function handlePageChange(e:MegaZineEvent):void {
			// Shift the queue to continue loading in the right place
			_currentPage = e.page;
			// Instead of completely rebuilding the queue it might be faster to rearrange it,
			// but as the queue will never be overly large (books only have that much of a
			// sensible size) I don't think it matters much.
			// Also, removing from the queue responsible for the element loading will be
			// a little inefficient, so...
			rebuildQueue();
		}
		
		/**
		 * Rebuild the complete loading queue, discarding the old one.
		 */
		private function rebuildQueue():void {
			var queue:LinkedList = new LinkedList();
			var i:int;
			// Load pages, left right, left right, ...
			for (i = 0; i < (_maxLoaded >> 1); i++) {
				queue.push(_currentPage - i);
				queue.push(_currentPage + 1 + i);
			}
			for (i = 0; i < _pages.length; i++) {
				if (Math.abs(_currentPage - i) >= (_maxLoaded >> 1)) {
					(_pages[i] as Page).unload((i & 1) == 0, _elementLoader);
				}
			}
			// Process pages
			while (queue.hasElements) {
				var page:uint = queue.pop();
				if (page < 0 || page >= _pages.length) continue;
				var even:Boolean = (page & 1) == 0;
				var s:String = (_pages[page] as Page).getLoadState(even);
				if (s == Page.UNLOADED || s == Page.LOADING_THUMB) {
					(_pages[page] as Page).load(even, _elementLoader);
				}
			}
		}
		
		/**
		 * Generate all thumbnails by once loading all pages in background and then unloading
		 * them again.
		 * @param page the number of the page to generate the thumbnail for.
		 */
		private function makeThumbs(page:uint = 0):void {
			// Producing thumbnails...
			_loadThumbActive = true;
			// Check if there are preferred pages, if there are none and only specified pages are to
			// be loaded stop loading.
			if (_loadPreferred.length > 0) {
				page = _loadPreferred.pop();
			} else if (_loadSpecifiedOnly) {
				_loadThumbActive = false;
				return;
			}
			while (page < _pages.length) {
				var even:Boolean = (page & 1) == 0;
				// Check if the page was already loaded, if yes try the next one...
				if (!_loadedOnce[page] && (_pages[page] as Page).getLoadState(even) == Page.UNLOADED) {
					(_pages[page] as Page).addEventListener(MegaZineEvent.PAGE_COMPLETE, thumbDone);
					(_pages[page] as Page).load(even, _elementLoader, true);
					// Started one, and we only load one thumb at a time, so exit here.
					return;
				}
				// Don't try to generate more when only loading specified, but try the next one form the
				// preferred pages array.
				if (_loadSpecifiedOnly) {
					setTimeout(makeThumbs, 100);
					return;
				}
				page++;
			}
			// Walked the whole array, check again just to make sure... this is necessary, because
			// we might have skipped one page because it was loading but the loading progress was
			// cancelled due to a page turn before it could generate a thumbnail.
			for (var i:uint = 0; i < _loadedOnce.length; i++) {
				if (!_loadedOnce[i]) {
					// One unloaded entry, try it (with a certain delay so that the display does not
					// get choppy)
					setTimeout(makeThumbs, 1000, i);
					return;
				}
			}
			_loadThumbActive = false;
			_allThumbsDone = true;
		}
		
		/**
		 * A page we generated a thumbnail for finished loading...
		 * @param e the event telling which page finished loading.
		 */
		private function thumbDone(e:MegaZineEvent):void {
			// Remove listener
			(_pages[e.page] as Page).removeEventListener(MegaZineEvent.PAGE_COMPLETE, thumbDone);
			// Continue with the next thumb
			setTimeout(makeThumbs, 100, e.page + 1);
		}
		
	}
	
}
