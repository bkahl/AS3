/*
Localizer - A class to help localizing text elements.
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
	
	import com.adobe.utils.DictionaryUtil;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	
	/**
	 * Used for localization purposes. Used to register elements (or rather: an
	 * elements property) for a given language string using some id. For a language string of
	 * any id it is possible to define any number of languages by a language shortcut (e.g. en).
	 * When switching between languages this class then updates all registered element properties
	 * accordingly.
	 * English is used as the default language, so if a string is registered for any other
	 * language and no string with that id exists in english it is copied to the english
	 * dictionary as well.
	 * 
	 * @author fnuecke
	 * @version 1.01
	 */
	public class Localizer extends EventDispatcher {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The current language */
		private var _currLang:String = "en";
		
		/** The default language */
		private var _default:String  = "en";
		
		/**
		 * A dictionary containing dictionaries for all known languages, mapping string ids to
		 * their actual values.
		 */
		private var _languages:Dictionary; // Dictionary // String
		
		/**
		 * A dictionary mapping objects to a dictionary which in turn maps property names to
		 * string ids of strings that should be used to populate that property.
		 */
		private var _objects:Dictionary; // Dictionary // Object {_id, _vars}
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new, empty localizer.
		 */
		public function Localizer(def:String) {
			_currLang = _default = def;
			_languages = new Dictionary();
			_languages[_default] = new Dictionary();
			// Use weak references. This automatically cleans up the registration dictionary.
			_objects = new Dictionary(true);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The default language.
		 * @return The default language.
		 */
		public function get defaultLanguage():String {
			return _default;
		}
		
		/**
		 * The currently used language. If set updates all registered objects to the
		 * given language.
		 * @param lang The id of the language to which to change.
		 */
		public function set language(lang:String):void {
			_currLang = lang;
			if (_languages[_currLang] != null) {
				// For every id for the given language...
				for (var id:String in _languages[_currLang]) {
					updateLangID(id);
				}
			}
			dispatchEvent(new LocalizerEvent(LocalizerEvent.LANGUAGE_CHANGED));
		}
		
		/**
		 * The currently used language. If set updates all registered objects to the
		 * given language.
		 * @return The currently used language.
		 */
		public function get language():String {
			return _currLang;
		}
		
		/**
		 * Returns an array with ids of the available languages, e.g. ["en", "de"]
		 * @return An array with known languages.
		 */
		public function getAvailableLanguages():Array {
			return DictionaryUtil.getKeys(_languages);
		}
		
		/**
		 * Get one specific string from a language.
		 * @param lang The language from which to get the string.
		 * @param id The id of the string.
		 * @return The content of the string with the given id in the given language.
		 */
		public function getLangString(lang:String, id:String):String {
			if (_languages[lang] == null || _languages[lang][id] == null) {
				return id + "_NOT_FOUND";
			} else {
				return _languages[lang][id];
			}
		}
		
		/**
		 * Registers a new object's property for a string id. Automatically updates the
		 * registered property for the current value. If that update fails the object is
		 * not registered and false is returned.
		 * @param object The object of which to register the property.
		 * @param propertyName The name of the property to register.
		 * @param id The id of the string for which to register.
		 * @param variable For strings allowing variables, pass them here.
		 * @return true if the object was successfully registered.
		 */
		public function registerObject(object:*, propertyName:String, id:String,
								       variables:Array = null):Boolean
		{
			if (updateProperty(object, propertyName, id, variables)) {
				// Seemed to work, register.
				if (_objects[object] == null) {
					_objects[object] = new Dictionary();
				}
				_objects[object][propertyName] = {_id : id, _vars : variables};
				return true;
			}
			return false;
		}
		
		/**
		 * Register a new language. Although strings may already be present for that language
		 * (for asynchronous loading of main definitions and additional definitions e.g.)
		 * calling this method actually triggers firing of the LANGUAGE_ADDED event.
		 * @param lang The identifier of the language.
		 */
		public function registerLanguage(lang:String):void {
			if (_languages[lang] == null) {
				_languages[lang] = new Dictionary();
			}
			dispatchEvent(new LocalizerEvent(LocalizerEvent.LANGUAGE_ADDED));
		}
		
		/**
		 * Registers a new string with the given id for the given language. If the string was
		 * already registered it will be overwritten with the new text.
		 * @param lang The language of the string.
		 * @param id The id of the string.
		 * @param text The actual string content.
		 */
		public function registerString(lang:String, id:String, text:String):void {
			if (lang == null) {
				lang = _default;
			}
			if (_languages[lang] == null) {
				_languages[lang] = new Dictionary();
			}
			_languages[lang][id] = text;
			
			// Copy to default if this type does not exist there yet.
			if (_languages[_default][id] == null) {
				_languages[_default][id] = text;
			}
			
			if (_currLang == lang) {
				updateLangID(id);
			}
		}
		
		/**
		 * Update all objects for the given language string
		 * @param id The id of the language string to update.
		 */
		private function updateLangID(id:String):void {
			// The loop is killer, but this way we can use weak references, automatically
			// cleaning up the registered objects.
			
			// Test every known object...
			for (var object:* in _objects) {
				// For a property...
				for (var propertyName:String in _objects[object]) {
					// That is bound to that id...
					if (_objects[object][propertyName]._id == id) {
						// And if it is try to update it.
						updateProperty(object, propertyName, id,
									   _objects[object][propertyName]._vars);
					}
				}
			}
		}
		
		/**
		 * Update property for an object, using variables if given.
		 * @param object The object having the property to update.
		 * @param propertyName Name of the property to update.
		 * @param id Id of the string to insert.
		 * @param variables Possible variables to insert into the string before setting
		 * the property.
		 * @return true on success, else false.
		 */
		private function updateProperty(object:*, propertyName:String,
										id:String, variables:Array):Boolean
		{
			var value:String = "Undefined String (" + _currLang + "): " + id;
			if (_languages[_currLang] != null
				&& _languages[_currLang][id] != null
				&& _languages[_currLang][id] != "")
			{
				value = _languages[_currLang][id];
			} else if (_languages[_default] != null
				&& _languages[_default][id] != null
				&& _languages[_default][id] != "")
			{
				value = _languages[_default][id];
			}
			try {
				if (variables) {
					for (var i:* in variables) {
						value = value.replace("$" + ((i as int) + 1), variables[i]);
					}
				}
				object[propertyName] = value;
				return true;
			} catch (e:Error) {
				// Failed, property probably does not exist and the
				// object is not a dynamic class.
			}
			return false;
		}
		
	}
	
}
