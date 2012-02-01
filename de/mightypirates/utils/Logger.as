/*
Logger - For centralized logging when trace is not an option
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
	
	import flash.events.*;
	
	/**
	 * May be used for centralized logging when trace is not an option (not debugging)
	 * @author fnuecke
	 */
	public class Logger {
		
		// ----------------------------------------------------------------------------------- //
		// Constants
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Errortype: None
		 * Disables logging.
		 */
		public static const TYPE_NONE:uint          = 0; // 000
		
		/**
		 * Errortype: Error
		 * Fatal errors making further execution impossible or useless.
		 * E.g. no pages defined.
		 */
		public static const TYPE_ERROR:uint         = 1; // 001
		
		/**
		 * Errortyp: Warning
		 * Stuff that the developer should definitely know about, but that does not create any
		 * problems for further execution.
		 * E.g. invalid attributes found (maybe mistyped?).
		 */
		public static const TYPE_WARNING:uint       = 2; // 010
		
		/**
		 * Errortype: Notice
		 * Minor things, status reports.
		 * E.g. done loading xml.
		 */
		public static const TYPE_NOTICE:uint        = 4; // 100
		
		/**
		 * Errortype: System Notice
		 * Status reports, displayed always, regardless of the error reporting level.
		 * E.g. disabling notices.
		 */
		public static const TYPE_SYSTEM_NOTICE:uint = 8; //1000
		
		/** All types, use for _errorReporting level */
		public static const TYPE_ALL:uint           = TYPE_ERROR | TYPE_WARNING | TYPE_NOTICE; // 111
		
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Error reporting level
		 * Starting with all so notices are shown before settings are read.
		 */
		private static var _level:uint = TYPE_ALL;
		
		/**
		 * The actual event dispatcher.
		 */
		private static var _dispatcher:EventDispatcher = new EventDispatcher();
		
		
		// ----------------------------------------------------------------------------------- //
		// Getter / Setter
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The current log level. See constants.
		 */
		public static function get level():uint {
			return _level;
		}
		
		/**
		 * The current log level. See constants.
		 */
		public static function set level(lvl:uint):void {
			_level = lvl;
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		public static function log(source:String, message:String, type:uint = TYPE_NOTICE):void {
			
			// Check if this kind of message should be handled
			if ((_level & type) > 0 || type == TYPE_SYSTEM_NOTICE) {
				
				var curr:Date = new Date();
				var time:String =
								(curr.getHours()   < 10 ? "0" : "") + curr.getHours()   + ":" + 
								(curr.getMinutes() < 10 ? "0" : "") + curr.getMinutes() + ":" + 
								(curr.getSeconds() < 10 ? "0" : "") + curr.getSeconds();
				
				// Check what it is, to add the prefix (timestamp and type)
				var base:String = "** [" + time + "] [" + Helper.padString(source, 15, Helper.PAD_CENTER);
				switch (type) {
					case TYPE_ERROR:
						message = base + "] Error:   " + message;
						break;
					case TYPE_WARNING:
						message = base + "] Warning: " + message;
						break;
					case TYPE_NOTICE:
						message = base + "] Notice:  " + message;
						break;
					case TYPE_SYSTEM_NOTICE:
						message = base + "] System:  " + message;
						break;
					default:
						message = base + "] Unknown: " + message;
						break;
				}
				
				// Dispatch an event with this message
				dispatchEvent(new LoggerEvent(LoggerEvent.MESSAGE, message));
				
			}
			
		}
		
		// ----------------------------------------------------------------------------------- //
		// Event dispatching stuff
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Registers an event listener object with an EventDispatcher object so that the listener
		 *  receives notification of an event. You can register event listeners on all nodes in the
		 *  display list for a specific type of event, phase, and priority.
		 *
		 * @param type              <String> The type of event.
		 * @param listener          <Function> The listener function that processes the event. This function must accept an event object
		 *                            as its only parameter and must return nothing, as this example shows:
		 *                            function(evt:Event):void
		 *                            The function can have any name.
		 * @param useCapture        <Boolean (default = false)> Determines whether the listener works in the capture phase or the target
		 *                            and bubbling phases. If useCapture is set to true, the
		 *                            listener processes the event only during the capture phase and not in the target or
		 *                            bubbling phase. If useCapture is false, the listener processes the event only
		 *                            during the target or bubbling phase. To listen for the event in all three phases, call
		 *                            addEventListener() twice, once with useCapture set to true,
		 *                            then again with useCapture set to false.
		 * @param priority          <int (default = 0)> The priority level of the event listener. Priorities are designated by a 32-bit integer. The higher the number, the higher the priority. All listeners with priority n are processed before listeners of priority n-1. If two or more listeners share the same priority, they are processed in the order in which they were added. The default priority is 0.
		 * @param useWeakReference  <Boolean (default = false)> Determines whether the reference to the listener is strong or weak. A strong
		 *                            reference (the default) prevents your listener from being garbage-collected. A weak
		 *                            reference does not. Class-level member functions are not subject to garbage
		 *                            collection, so you can set useWeakReference to true for
		 *                            class-level member functions without subjecting them to garbage collection. If you set
		 *                            useWeakReference to true for a listener that is a nested inner
		 *                            function, the function will be garbge-collected and no longer persistent. If you create
		 *                            references to the inner function (save it in another variable) then it is not
		 *                            garbage-collected and stays persistent.
		 */
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * Dispatches an event into the event flow. The event target is the
		 *  EventDispatcher object upon which dispatchEvent() is called.
		 *
		 * @param event             <Event> The event object dispatched into the event flow.
		 * @return                  <Boolean> A value of true unless preventDefault() is called on the event,
		 *                            in which case it returns false.
		 */
		public static function dispatchEvent(event:Event):Boolean {
			return _dispatcher.dispatchEvent(event);
		}
		
		/**
		 * Checks whether the EventDispatcher object has any listeners registered for a specific type
		 *  of event. This allows you to determine where an EventDispatcher object has altered handling of an event type in the event flow hierarchy. To determine whether
		 *  a specific event type will actually trigger an event listener, use IEventDispatcher.willTrigger().
		 *
		 * @param type              <String> The type of event.
		 * @return                  <Boolean> A value of true if a listener of the specified type is registered; false otherwise.
		 */
		public static function hasEventListener(type:String):Boolean {
			return _dispatcher.hasEventListener(type);
		}
		
		/**
		 * Removes a listener from the EventDispatcher object. If there is no matching listener
		 *  registered with the EventDispatcher object, a call to this method has no effect.
		 *
		 * @param type              <String> The type of event.
		 * @param listener          <Function> The listener object to remove.
		 * @param useCapture        <Boolean (default = false)> Specifies whether the listener was registered for the capture phase or the target and bubbling phases. If the listener was registered for both the capture phase and the target and bubbling phases, two calls to removeEventListener() are required to remove both: one call with useCapture set to true, and another call with useCapture set to false.
		 */
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * Checks whether an event listener is registered with this EventDispatcher object or any of its ancestors for the specified event type. This method returns true if an event listener is triggered during any phase of the event flow when an event of the specified type is dispatched to this EventDispatcher object or any of its descendants.
		 *
		 * @param type              <String> The type of event.
		 * @return                  <Boolean> A value of true if a listener of the specified type will be triggered; false otherwise.
		 */
		public static function willTrigger(type:String):Boolean {
			return _dispatcher.willTrigger(type);
		}
		
	}
	
}