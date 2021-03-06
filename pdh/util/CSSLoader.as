﻿package pdh.util{	import flash.events.Event;  	import flash.net.URLLoader;  	import flash.net.URLRequest;  	import flash.text.StyleSheet;  		import flash.events.EventDispatcher;    public class CSSLoader extends EventDispatcher    {		public static const CSS_LOADED	:String = "css loaded"		private var loader				:URLLoader;  		public var sheet			:StyleSheet;								public function CSSLoader(val:String)         {			var req:URLRequest = new URLRequest(val);     			 loader = new URLLoader();  			 loader.addEventListener(Event.COMPLETE, onCSSFileLoaded);  			 loader.load(req);  		}                 public function onCSSFileLoaded(event:Event):void           {  			 sheet = new StyleSheet();               sheet.parseCSS(loader.data);  			 dispatchEvent(new Event(CSS_LOADED));         }  		 		 public function getStyles():StyleSheet		 {			return sheet; 		 }							} // end class} // end package