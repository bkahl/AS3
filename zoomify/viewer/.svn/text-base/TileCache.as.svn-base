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

package zoomify.viewer
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.Dictionary;
    	import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import zoomify.viewer.TileDataLoader;
	import zoomify.events.TileEvent;
	import zoomify.events.TileProgressEvent;

	public class TileCache extends EventDispatcher
	{		
		
	
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: INIT METHODS :::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		private var cacheArray:Array;
		private var cacheLUT:Object;
		private var imagePath:String;
		private var limitsArray:Array;
		private var widthScale:Number;
		private var heightScale:Number;
		private var lastReqArray:Array;
		private var queue:Dictionary;

		static private const MAX_CACHE_SIZE:Number = 100;

		public function TileCache():void {
			cacheArray = [];
			cacheLUT = {};
			limitsArray = [];
			lastReqArray = [];
			queue = new Dictionary();
			addEventListener(TileEvent.READY, tileReadyHandler, false, 0, true);
		}

		private function tileReadyHandler(event:TileEvent):void {
			if(event.t != 0 || event.r != 0 || event.c != 0) { return; }
			var tile:Bitmap = convertTileDataToBitmap(0, 0, 0);
			if(tile != null) {
				event.loader.immortal = true;
			}
		}
		
		public function convertTileDataToBitmap(t:uint, r:int, c:int):Bitmap {
			var dt:TileDataLoader = cacheLUT[t + "|" + r + "|" + c];
			if(dt == null) { return  null; }
			return dt.content as Bitmap;
		}
		
		
						
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::: GET & SET METHODS ::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public function setPath(newImagePath:String):void {
			imagePath = newImagePath;
		}
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::: CORE METHODS :::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		public function loadTile(t:uint, r:int, c:int):Boolean {
			var dt:TileDataLoader = cacheLUT[t + "|" + r + "|" + c];
			if(r < 0 || c < 0 || dt != null || imagePath == null) {
				if(dt != null) {
					var x:int = cacheArray.indexOf(dt);
					if(x != -1) { cacheArray.push(cacheArray.splice(x, 1)[0]); }
					lastReqArray.push(dt);	
				}
				return true;
			}
			var offset:Number = r * Math.ceil((1 << t) * widthScale) + c;
			for(var i:uint = 0; i < t; i++) { offset += limitsArray[i]; }
			var loader:TileDataLoader = new TileDataLoader(Math.floor(offset / 256), t, r, c);
			loader.load(new URLRequest(imagePath + "/" + "TileGroup" + Math.floor(offset / 256) + "/" + t + "-" + c + "-" + r + ".jpg"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, tileLoaded);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			cacheLUT[t + "|" + r + "|" + c] = loader;
			queue[t + "|" + r + "|" + c] = loader;
			cacheArray.push(loader);
			lastReqArray.push(loader);
			return false;
		}
		
		private function tileIsReady(loader:TileDataLoader, t:uint, r:uint, c:uint):void {
			dispatchEvent(new TileEvent(TileEvent.READY, loader, loader.content as Bitmap, t, r, c));
		}
		
		protected function dispatchProgressEvent():void {
			var files:uint = 0;
			var bytesTotal:uint = 0;
			var bytesLoaded:uint = 0;
			for(var key:String in queue) {
				var loader:TileDataLoader = queue[key] as TileDataLoader;
				if(loader != null) {
					var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
					var bl:uint = loaderInfo.bytesLoaded;
					var bt:uint = loaderInfo.bytesTotal;
					if(bl >= 0 && bt >= 0) {
						files++;
						bytesTotal += bt;
						bytesLoaded += bl;
					}
				}
			}
			dispatchEvent(new TileProgressEvent(TileProgressEvent.TILE_PROGRESS, files, bytesTotal, bytesLoaded));
		}
		
		public function purge(maxCount:uint = MAX_CACHE_SIZE):void {
			while(cacheArray.length > maxCount) {
				var tileToPurge:TileDataLoader = null;
				for(var i:int = 0; i < cacheArray.length; i++) {
					var dl:TileDataLoader = cacheArray[i] as TileDataLoader;
					if(dl && (!dl.immortal || maxCount == 0) && lastReqArray.indexOf(dl) == -1) {
						tileToPurge = dl;
						break;
					}
				}
				if(tileToPurge == null) {
					break;
				}
				dispatchEvent(new TileEvent(TileEvent.REMOVED, tileToPurge, tileToPurge.content as Bitmap, tileToPurge.t, tileToPurge.r, tileToPurge.c));
				delete queue[tileToPurge.t + "|" + tileToPurge.r + "|" + tileToPurge.c];
				cacheLUT[tileToPurge.t + "|" + tileToPurge.r + "|" + tileToPurge.c] = null;
				cacheArray.shift();
				var content:Bitmap = tileToPurge.content as Bitmap;
				if(content) {
					content.bitmapData.dispose();
				}
			}
			lastReqArray = [];
		}		
		
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: EVENT HANDLERS :::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		private function tileLoaded(e:Event):void {
			var loader:TileDataLoader = e.target.loader as TileDataLoader;
			delete queue[loader.t + "|" + loader.r + "|" + loader.c];
			dispatchProgressEvent();
			tileIsReady(loader, loader.t, loader.r, loader.c);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			for(var i:uint = 0; i < cacheArray.length; i++) {
				if(cacheArray[i].contentLoaderInfo == event.target) {
					delete queue[cacheArray[i].t + "|" + cacheArray[i].r + "|" + cacheArray[i].c];
				}
			}
			dispatchProgressEvent();
		}

		private function progress(event:ProgressEvent):void {
			dispatchProgressEvent();
		}
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::: SUPPORT METHODS ::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
				
		public function calculatePathLimits(tileSize:uint, fullWidth:uint, fullHeight:uint):void {
			var max:Number = Math.max(fullWidth, fullHeight ) / Number(tileSize);
			for(var i:uint = 0; (1 << i) < max; i++) {
				widthScale = fullWidth / ((1 << i) * tileSize);
				heightScale = fullHeight / ((1 << i) * tileSize);
				if(max > (1 << i)) { widthScale = fullWidth / ((1 << (i + 1)) * tileSize); }
				if(max > (1 << i)) { heightScale = fullHeight / ((1 << (i + 1)) * tileSize); }
			}
			limitsArray = [];
			for(var t:uint = 0; t <= i; t++) {
				var tileNumber:uint = 0;
				var n:uint = 1 << t;
				limitsArray.push(Math.ceil(widthScale * n) * Math.ceil(heightScale * n));
			}
		}
		
		// Debugging tool.
		public function getTileData(t:uint, r:int, c:int):TileDataLoader {
			return cacheLUT[t + "|" + r + "|" + c];
		}
	}
}
