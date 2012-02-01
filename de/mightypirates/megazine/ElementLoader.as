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
	
	import de.mightypirates.megazine.Element;
	import de.mightypirates.megazine.events.MegaZineEvent;
	import de.mightypirates.utils.LinkedList;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.setTimeout;
	
	/**
	 * This object represents a loader that is used to load any elements that are on the pages.
	 * Elements are added to a queue, and a certain number is loaded in parallel.
	 * Added elements can be removed again, either simply deleting the queue entry or canceling
	 * the current loading process.
	 * 
	 * @author fnuecke
	 */
	internal class ElementLoader {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		private var _currLoading:uint;
		
		private var _maxParallel:uint;
		
		private var _queue:LinkedList;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		public function ElementLoader(maxParallel:uint = 4) {
			_maxParallel = maxParallel;
			_currLoading = 0;
			_queue = new LinkedList();
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Add an element to the loading queue. The loading queue is a fifo queue.
		 * @param element The element to add.
		 * @param page Prioritize the element, means load it first.
		 */
		public function addElement(element:Element, prioritize:Boolean = false):void {
			if (prioritize) {
				_queue.push(element);
			} else {
				_queue.unshift(element);
			}
			setTimeout(update, 100);
		}
		
		/**
		 * Add a batch of element to add to the loading queue. The loading queue is a fifo queue.
		 * @param element The elements to add.
		 */
		public function addElements(elements:Array):void {
			for each (var element:Element in elements) {
				_queue.push(element);
			}
			setTimeout(update, 100);
		}
		
		/**
		 * Remove an element from the queue.
		 * @param element The element to remove.
		 */
		public function removeElement(element:Element):void {
			_queue.remove(element);
		}
		
		/** Updater, tests if a slot is free and if yes tries to fill it */
		private function update():void {
			if (_currLoading < _maxParallel && _queue.hasElements) {
				// Find an element that is not loaded.
				var element:Element;
				do {
					element = _queue.pop() as Element;
				}
				while (element && element.element);
				// If an unloaded element was found load it.
				if (element) {
					// Register listeners for failure / success
					element.addEventListener(MegaZineEvent.ELEMENT_COMPLETE, onElementEvent);
					element.addEventListener(IOErrorEvent.IO_ERROR, onElementEvent);
					// Occupy slot and begin loading.
					_currLoading++;
					element.elementLoader = this;
					element.load();
					// Wait until triggering the next element.
					setTimeout(update, 50);
				}
			}
		}
		
		private function onElementEvent(e:Event):void {
			// Complete or error, don't care, free slot.
			_currLoading--;
			try {
				e.target.removeEventListener(MegaZineEvent.ELEMENT_COMPLETE, onElementEvent);
				e.target.removeEventListener(IOErrorEvent.IO_ERROR, onElementEvent);
			} catch (e:Error) { }
			setTimeout(update, 100);
		}
		
	}
	
}
