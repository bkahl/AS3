/*
Helper - Some helper methods for variable formatting
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
	import flash.utils.Dictionary;
	
	/**
	 * Contains helper methods for validating values of any type, meant to be used
	 * with data loaded from xml files (meaning data that might be null, in which
	 * case the default value is returned). Meant to ease formatting loaded data.
	 * 
	 * @author fnuecke
	 * @version 1.12
	 */
	public class Helper {
		
		/** For the padString method, centered padding */
		public static const PAD_CENTER:String = "pad_center";
		
		/** For the padString method, left padding */
		public static const PAD_LEFT:String   = "pad_left";
		
		/** For the padString method, right padding */
		public static const PAD_RIGHT:String  = "pad_right";
		
		/**
		 * Pads a string with the given char (or string) until it reaches the specified length.
		 * @param text   The original text.
		 * @param length How long the string should be afterwards.
		 * @param pad    Padding type. See constants.
		 * @param char   The char to pad with.
		 * @return The new string.
		 */
		public static function padString(text:String, length:uint = 0,
										 pad:String = PAD_LEFT, char:String = " "):String {
			if (text != null && char != null && char.length > 0) {
				var lastLeft:Boolean = true;
				while (text.length < length) {
					if (pad == PAD_LEFT || (pad == PAD_CENTER && !lastLeft)) {
						lastLeft = !lastLeft;
						text = char + text;
					} else {
						lastLeft = !lastLeft;
						text += char;
					}
				}
				// In case char was a string cut off what's too much
				text = text.substr(0, length);
			}
			return text;
		}
		
		/**
		 * Rounds a number, keeping a given amount of digits.
		 * @param num The number to round.
		 * @param digits The number of digits to keep.
		 * @param up Round up or down.
		 * @return The rounded number.
		 */
		public static function round(num:Number, digits:uint = 4, up:Boolean = true):Number {
			var pot:Number = Math.pow(10, digits);
			num = num * pot;
			return (up ? Math.ceil(num) : Math.floor(num)) / pot;
		}
		
		/**
		 * Sorts a dictionary by it's key values. Uses the Array.sort() method after extracting
		 * the keys using the DictionaryUtils.getKeys() method. The input dictionary will not be
		 * modified.
		 * @param dict The dictionary which to sort.
		 * @return The sorted dictionary.
		 */
		public static function sortDictByKeys(dict:Dictionary):Dictionary {
			var keys:Array = DictionaryUtil.getKeys(dict);
			keys.sort();
			var d:Dictionary = new Dictionary();
			for (var key:* in keys) {
				d[key] = dict[key];
			}
			return d;
		}
		
		/**
		 * Shortens a string to the given length by removing the middle part, replacing it with "...".
		 * If a allowed string length is too short for that the "..." will not be added and only the
		 * beginning of the string will be returned.
		 * @param text The raw string.
		 * @param len The max length.
		 * @return the shortened string.
		 */
		public static function trimString(text:String, len:uint):String {
			if (text != null && text.length > len) {
				if (len < 5) {
					return text.substr(0, len);
				} else {
					len = (len - 3) >> 1;
					// Weighted trimming - take 1/4 of the beginning and 3/4 of the ending.
					return text.substr(0, len >> 1) + "..." + text.substr(text.length - len - (len >> 1), len + (len >> 1));
				}
			} else {
				return text;
			}
		}
		
		/**
		 * XML input validation and formatting
		 * @param raw The raw data.
		 * @param def The default value.
		 * @return formatted data.
		 */
		public static function validateBoolean(raw:*, def:Boolean):Boolean {
			if (raw != undefined && raw != null) {
				return String(raw) == "true";
			} else {
				return def;
			}
		}
		
		/**
		 * XML input validation and formatting
		 * @param raw The raw data.
		 * @param def The default value.
		 * @return formatted data.
		 */
		public static function validateString(raw:*, def:String):String {
			if (raw != undefined && raw != null) {
				return String(raw);
			} else {
				return def;
			}
		}
		
		/**
		 * XML input validation and formatting
		 * @param raw The raw data.
		 * @param def The default value.
		 * @param low Minimum value, optional (types minimum per default).
		 * @param high Maximum value, optional (types maximum per default).
		 * @return formatted data.
		 */
		public static function validateInt(raw:*, def:int,
								  low:int = int.MIN_VALUE, high:int = int.MAX_VALUE):int {
			if (raw != undefined && raw != null) {
				if (int(raw) < low) {
					return low;
				} else if (int(raw) > high) {
					return high;
				} else {
					return int(raw);
				}
			} else {
				return def;
			}
		}
		
		/**
		 * XML input validation and formatting
		 * @param raw The raw data.
		 * @param def The default value.
		 * @param low Minimum value, optional (types minimum per default).
		 * @param high Maximum value, optional (types maximum per default).
		 * @return formatted data.
		 */
		public static function validateUInt(raw:*, def:uint,
								  low:uint = uint.MIN_VALUE, high:uint = uint.MAX_VALUE):uint {
			if (raw != undefined && raw != null) {
				trace(raw);
				if (uint(raw) < low) {
					return low;
				} else if (uint(raw) > high) {
					return high;
				} else {
					return uint(raw);
				}
			} else {
				return def;
			}
		}
		
		/**
		 * XML input validation and formatting
		 * @param raw The raw data.
		 * @param def The default value.
		 * @param low Minimum value, optional (types minimum per default).
		 * @param high Maximum value, optional (types maximum per default).
		 * @return formatted data.
		 */
		public static function validateNumber(raw:*, def:Number,
								  low:Number = Number.MIN_VALUE, high:Number = Number.MAX_VALUE):Number {
			if (raw != undefined && raw != null) {
				if (Number(raw) < low) {
					return low;
				} else if (Number(raw) > high) {
					return high;
				} else {
					return Number(raw);
				}
			} else {
				return def;
			}
		}
		
	}
	
}