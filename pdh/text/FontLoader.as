﻿package pdh.text{	import pdh.events.FontLoaderEvent;	import flash.events.EventDispatcher;	import flash.display.Loader;	import flash.events.Event;	import flash.events.ProgressEvent;	import flash.net.URLRequest;	import flash.text.Font;	import flash.system.ApplicationDomain;	import flash.utils.Dictionary;		public class FontLoader extends EventDispatcher	{		protected var _fontsDomain			:ApplicationDomain;		private var loader					:Loader;		protected var fontArray				:Array;				public function Fonts()		{					}				protected function init(file:String, chosen:Array = null)		{			fontArray = chosen;			loadFont(file);		}		private function loadFont(url:String):void		{			loader = new Loader();			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fontLoaded);			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, fontLoading);			loader.load(new URLRequest(url));		}		protected function fontLoaded(e:Event):void		{						loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fontLoaded);			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, fontLoading);						_fontsDomain = loader.contentLoaderInfo.applicationDomain;						var f_arr:Array = Font.enumerateFonts(false);			trace("------->" + f_arr);						// register fonts			for (var i:int = 0; i < fontArray.length; i++) {				registerFont(fontArray[i]);			}					}				protected function fontLoading(e:ProgressEvent):void		{			var pcent:Number = e.bytesLoaded / e.bytesTotal;			dispatchEvent(new FontLoaderEvent(FontLoaderEvent.LOADING, {value:pcent}));		}						protected function getName(val:String):String		{			var test:Array = val.toString().split(" ");			var tests:String = test[1].substring(0, test[1].length - 1);			return tests;		}				public function registerFont(fontname:String):void		{			Font.registerFont(getFontClass(fontname));		}							public function getFontClass(id:String):Class		{			return _fontsDomain.getDefinition(id)  as  Class;		}			}	}