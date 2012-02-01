//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// Copyright Zoomify, Inc., 1999-2008. All rights reserved.
//
// You may modify but not redistribute this source code file. Files
// created based on this source file may only be distributed in compiled
// SWF form with import protection enabled (see Adobe Flash documentation).
//
// Additional terms apply. Please see the Zoomify License Agreement
// included with this product for complete license terms.
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

package zoomify.utils
{
	import flash.utils.Dictionary;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.EventDispatcher;
	import zoomify.utils.Resources;
		
	public class Parameters extends EventDispatcher
	{
	
	
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: INIT METHODS :::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		protected var dict:Dictionary;
		protected var xmlParamsMap:Dictionary;
		
		public function Parameters(params:Object = null):void
		{
			dict = new Dictionary();
			initializeXMLParamsMap();
			initialize(params);
		}
		
		public function initialize(params:Object):void {
			if(params != null) {
				for(var key:String in params) {
					if(params[key] != "") {
						dict[key] = params[key];
					}
				}
			}
		}
		
		public function load(url:String):void {
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.load(request);
		}
		
		protected function completeHandler(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			if(loader) {
				var xml:XML = new XML(loader.data);
				var attrs:XMLList = xml.@*;
				for(var i:uint = 0; i < attrs.length(); i++) {
					var attr:XML = attrs[i] as XML;
					var name:String = attr.name().localName.toUpperCase();
					var value:String = attr.toString();
					var zoomifyParamName:String = xmlParamsMap[name] as String;
					if(zoomifyParamName && zoomifyParamName != "") {
						dict[zoomifyParamName] = value;
					}
				}
			}
			dispatchEvent(event.clone());
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(event.clone());
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void {
			dispatchEvent(event.clone());
		}
		
		protected function initializeXMLParamsMap():void {
			xmlParamsMap = new Dictionary();
			xmlParamsMap["IMAGEPATH"] = "zoomifyImagePath";
			xmlParamsMap["INITIALX"] = "zoomifyInitialX";
			xmlParamsMap["INITIALY"] = "zoomifyInitialY";
			xmlParamsMap["INITIALZOOM"] = "zoomifyInitialZoom";
			xmlParamsMap["MINZOOM"] = "zoomifyMinZoom";
			xmlParamsMap["MAXZOOM"] = "zoomifyMaxZoom";
			xmlParamsMap["SPLASHSCREEN"] = "zoomifySplashScreen";
			xmlParamsMap["CLICKZOOM"] = "zoomifyClickZoom";
			xmlParamsMap["ZOOMSPEED"] = "zoomifyZoomSpeed";
			xmlParamsMap["FADEINSPEED"] = "zoomifyFadeInSpeed";
			xmlParamsMap["PANCONSTRAIN"] = "zoomifyPanConstrain";
			xmlParamsMap["TOOLBARVISIBLE"] = "zoomifyToolbarVisible";
			xmlParamsMap["TOOLBARSPACING"] = "zoomifyToolbarSpacing";
			xmlParamsMap["TOOLBARSKINXMLPATH"] = "zoomifyToolbarSkinXMLPath";
			xmlParamsMap["TOOLBARTOOLTIPS"] = "zoomifyToolbarTooltips";
			xmlParamsMap["SLIDERVISIBLE"] = "zoomifySliderVisible";
			xmlParamsMap["TOOLBARLOGO"] = "zoomifyToolbarLogo";
			xmlParamsMap["NAVIGATORVISIBLE"] = "zoomifyNavigatorVisible";
			xmlParamsMap["NAVIGATORWIDTH"] = "zoomifyNavigatorWidth";
			xmlParamsMap["NAVIGATORHEIGHT"] = "zoomifyNavigatorHeight";
			xmlParamsMap["NAVIGATORFIT"] = "zoomifyNavigatorFit";
			xmlParamsMap["NAVIGATORX"] = "zoomifyNavigatorX";
			xmlParamsMap["NAVIGATORY"] = "zoomifyNavigatorY";
			xmlParamsMap["EVENTS"] = "zoomifyEvents";
		}
		
		
				
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::: GET & SET METHODS ::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public function getParameterAsString(key:String, def:String = ""):String {
			var value:String = dict[key] as String;
			return (value != null && value != "") ? value : def;
		}

		public function getParameterAsNumber(key:String, def:Number = 0):Number {
			var value:Number = parseFloat(dict[key] as String);
			return !isNaN(value) ? value : def;
		}
	}
}
