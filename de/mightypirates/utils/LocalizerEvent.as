/*
LocalizerEvent - Fired by the Localizer class.
Copyright (c) 2007-2008 Florian Nuecke

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package de.mightypirates.utils {
	
	import flash.events.Event;
	
	/**
	 * Event fired by the Localizer class when the language is changed or a new language is
	 * added.
	 * @author fnuecke
	 * @version 1.01
	 */
	public class LocalizerEvent extends Event {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Fired when a new language is added to the localizer.
		 * This is fired before the string that triggered the event is actually added, i.e.
		 * when this is fired there are no actual entries for the new language.
		 */
		public static const LANGUAGE_ADDED:String   = "lang_added";
		
		/**
		 * Fired when the current language was changed, i.e. the language property already
		 * contains the new value.
		 */
		public static const LANGUAGE_CHANGED:String = "lang_changed";
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new localizer event...
		 * @param type See constants.
		 */
		public function LocalizerEvent(type:String) { 
			super(type);
		}
		
	}
	
}
