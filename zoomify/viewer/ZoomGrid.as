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
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.net.*;
	import flash.text.*;
   	import flash.utils.*;

	import zoomify.ZoomifyViewer;
	import zoomify.viewer.TileCache;
	import zoomify.viewer.TileDataLoader;
	import zoomify.events.TileEvent;
	import zoomify.utils.Tooltip;

	public class ZoomGrid extends EventDispatcher
	{
	
	
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: INIT METHODS :::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public var numTiles:uint;
		public var expectedTiles:uint;

		private var _viewer:ZoomifyViewer;
		private var parent_mc:Sprite;
		private var canvas:Sprite;
		private var canvasSprite:Sprite;
		private var priorBitmap:Bitmap;
		private var background:Sprite; 
		private var tileCache:TileCache;
		private var hotspotsInUse:int = 0;

		private var currentTilesArray:Array;
		private var tilesToLoad:uint = 0;
		private var tilesLoaded:uint = 0;
		private var backgroundTilesToLoad:uint = 0;
		private var backgroundTilesLoaded:uint = 0;

		private var visWidth:Number;
		private var visHeight:Number;
		private var tileSize:uint;
		private var numTilesX:uint;
		private var numTilesY:uint;
		private var tileX:int = 0;
		private var tileY:int = 0;
		private var tier:uint = 4;
		private var maxTier:uint;
		private var fullWidth:uint;
		private var fullHeight:uint;
		private var tierWidth:Number;
		private var widthScale:Number;
		private var heightScale:Number;
		private var maxTileX:uint;
		private var maxTileY:uint;
		public var backgroundTier:int = -1;
		private var padImage:uint = 0; // Creates border for debugging.
		private var imageW:uint;
		private var imageH:uint;
		private var priorTileX:int;
		private var priorTileY:int;
		private var priorZoom:Number;
		private var scaling:Boolean = false;
		private var firstFullViewDrawn:Boolean = false;
		private var firstTileDrawn:Boolean = false;

		private var _enabled:Boolean = true;

		private var fadeInTimer:Timer;
		private var fadeInSpeed:Number = 300;
		
		private var panConstrain:Boolean = true;
		private var eventsEnabled:Boolean = false;
		
		protected var tooltipTimer:Timer;
		protected var tooltipParent:Sprite;
		
		protected var ratioBackgroundToFullWidth:Number = 1;
		
		public function ZoomGrid(parent:Sprite, tc:TileCache):void	
		{
			tileCache = tc;
			tileCache.addEventListener(TileEvent.READY, tileLoaded, false, 0, true);
			tileCache.addEventListener(TileEvent.REMOVED, tileUnloaded, false, 0, true);
			
			currentTilesArray = [];

			parent_mc = parent;
			canvas = new Sprite();
			background = new Sprite();
			canvasSprite = new Sprite();
			priorBitmap = new Bitmap();
			priorBitmap.smoothing = true;
			canvas.addChild(background);
			canvas.addChild(priorBitmap);
			canvas.addChild(canvasSprite);
			
			canvas.buttonMode = true;
			canvas.useHandCursor = true;
			parent_mc.addChild(canvas);
			
			fadeInTimer = new Timer(50, 0);
			fadeInTimer.addEventListener("timer", fadeInTimerHandler, false, 0, true);
			fadeInTimer.start();
					
			addEventListener("viewerFirstTileDrawInternal", firstTileDrawGridInternalHandler, false, 0, true);
			addEventListener("viewerFirstFullViewDrawInternal", firstFullViewDrawGridInternalHandler, false, 0, true);
			
			tooltipTimer = new Timer(500, 1);
		}
		
		
		
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::: GET & SET METHODS ::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		public function get viewer():ZoomifyViewer {
			return _viewer;
		}
		
		public function set viewer(newViewer:ZoomifyViewer):void {
			_viewer = newViewer;
		}
		
		public function get x():Number {
			var mult:Number = 1 << (maxTier - tier);
			var visW:Number = visWidth * mult / canvas.scaleX;
			var relX:Number = (tileX * tileSize - (canvas.x / canvas.scaleX)) * mult;
			return relX + (visW / 2);
		}
		
		public function set x(value:Number):void {
			if(canvas) {
				var mult:Number = 1 << (maxTier - tier);
				var visW:Number = visWidth * mult / canvas.scaleX;
				value = value - (visW / 2);
				canvas.x = (value / mult - (tileX * tileSize)) * -canvas.scaleX;
			}
		}
		
		public function get y():Number {
			var mult:Number = 1 << (maxTier - tier);
			var visH:Number = visHeight * mult / canvas.scaleX;
			var relY:Number = (tileY * tileSize - (canvas.y / canvas.scaleY)) * mult;
			return relY + (visH / 2);
		}
		
		public function set y(value:Number):void {
			if(canvas) {
				var mult:Number = 1 << (maxTier - tier);
				var visH:Number = visHeight * mult / canvas.scaleX;
				value = value - (visH / 2);
				canvas.y = (value / mult - (tileY * tileSize)) * -canvas.scaleY;
			}
		}	
		
		public function get xImageSpan():Number {
			return 2 * x / fullWidth - 1;
		}
		
		public function set xImageSpan(value:Number):void {
			if(canvas) {
				var mult:Number = 1 << (maxTier - tier);
				var visW:Number = visWidth * mult / canvas.scaleX;
				value = (value * fullWidth / 2) - (visW / 2) + (fullWidth / 2);
				canvas.x = (value / mult - (tileX * tileSize)) * -canvas.scaleX;
			}
		}
		
		public function get yImageSpan():Number {
			return 2 * y / fullHeight - 1;
		}	
		
		public function set yImageSpan(value:Number):void {
			if(canvas) {
				var mult:Number = 1 << (maxTier - tier);
				var visH:Number = visHeight * mult / canvas.scaleX;
				value = (value * fullHeight / 2) - (visH / 2) + (fullHeight / 2);
				canvas.y = (value / mult - (tileY * tileSize)) * -canvas.scaleY;
			}
		}
				
		public function get scaleX():Number {
			return canvas.scaleX;
		}
				
		public function set scaleX(value:Number):void {
			if(canvas) {
				canvas.scaleX = value;
			}
		}	
				
		public function get scaleY():Number {
			return canvas.scaleY;
		}
				
		public function set scaleY(value:Number):void {
			if(canvas) {
				canvas.scaleY = value;
			}
		}
		
		public function getFadeInSpeed():Number {
			return fadeInSpeed;
		}
		
		public function setFadeInSpeed(durationInMilliseconds:Number):void {
			fadeInSpeed = durationInMilliseconds;
		}
		
		public function getPanConstrain():Boolean {
			return panConstrain;
		}
		
		public function setPanConstrain(value:Boolean):void {
			panConstrain = value;
		}

		public function getMousePosition():Point {
			return new Point(
				((background.mouseX * background.scaleX) / background.width),
				((background.mouseY * background.scaleY) / background.height)
			);
		}
				
		public function getCurrentTier():int {
			return tier;
		}
		
		public function getMaxTier():uint {
			return maxTier;
		}
		
		public function setMaxTier(value:uint):void {
			maxTier = value;
		}
		
		public function getCanvasWidth():Number {
			return numTilesX * tileSize;
		}
		
		public function getCanvasHeight():Number {
			return numTilesY * tileSize;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void {
			canvas.buttonMode = value;
			canvas.useHandCursor = value;
			_enabled = value;
		}
		
		public function active(value:Boolean):void {
			// Toggle interactivity by setting grid's container clip visibility.
			parent_mc.visible = value;
			if(!value) {
				priorBitmap.bitmapData = null;
			}
		}
		
		public function setEventsEnabled(value:Boolean):void {
			eventsEnabled = value;
		}
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::: CORE METHODS :::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
									
		public function configureCanvas(tlS:uint, visW:Number, visH:Number, fullW:uint, fullH:uint, t:int, tScaleDownThreshold:Number, tWidthsInTilesArray:Array, tHeightsInTilesArray:Array):void {
			visWidth = visW;
			visHeight = visH;
			tileSize = tlS;
			tier = t;
			fullWidth = fullW; 
			fullHeight = fullH; 
			// Determine max tier.
			var max:Number = Math.max(fullWidth, fullHeight) / Number(tileSize);
			for(var i:uint = 0; (1 << i) < max; i++) {
				widthScale = fullWidth / ((1 << i) * tileSize);
				heightScale = fullHeight / ((1 << i) * tileSize);
				if(max > (1 << i)) { widthScale = fullWidth / ((1 << (i + 1)) * tileSize); }
				if(max > (1 << i)) { heightScale = fullHeight / ((1 << (i + 1)) * tileSize); }
			}
			imageW = widthScale * fullWidth;
			imageH = heightScale * fullHeight;
			var r:uint;
			var c:uint;
			var n:uint = 1<<t;
			for(r = 0; r < n; r++) {
				if((r * tileSize) > (n * tileSize * widthScale)) {
					break;
				}
				maxTileX = r;
			}
			for(c = 0; c < n; c++) {
				if((c * tileSize) > (n * tileSize * heightScale)) {
					break;
				}
				maxTileY = c;
			}
			tileX = 0;
			tileY = 0;
			// Divide by scale down threshold (at 0.5 double the area is needed).
			numTilesX = Math.ceil(visWidth / tileSize) / tScaleDownThreshold + 1;
			numTilesY = Math.ceil(visHeight / tileSize) / tScaleDownThreshold + 1; 
			if(backgroundTier == -1) {
				background.graphics.clear();
				backgroundTier = Math.round(i / 3); // DEV NOTE: Round for best tier choice (not ceil, not just uint).
				if(backgroundTier > 2) {  // DEV NOTE: Using value 3 would cause avg 1MB init impact.
					backgroundTier = 2;
				} 
				var tWInT:uint = tWidthsInTilesArray[backgroundTier];
				var tHInT:uint = tHeightsInTilesArray[backgroundTier];
				for (var rowCounter:Number = 0; rowCounter <= tHInT-1; rowCounter++) {
					for (var columnCounter:Number = 0; columnCounter <= tWInT-1; columnCounter++) {
						backgroundTilesToLoad +=1;
						tileCache.loadTile(backgroundTier, rowCounter, columnCounter);
					}			
				}	
				background.scaleY = background.scaleX = (1 << tier) / Number(1 << backgroundTier);
			}
		}
		
		public function updateCanvas(tlS:uint, fullW:uint, fullH:uint, t:int, tWidthsInTiles:Array, tHeightsInTiles:Array):void {
			// Reset key variables.
			tileSize = tlS;
			tier = t;
			fullWidth = fullW; 
			fullHeight = fullH;			
			// Recalculate key limits.
			var max:Number = Math.max(fullWidth, fullHeight) / Number(tileSize);
			for(var i:uint = 0; (1 << i) < max; i++) {
				widthScale = fullWidth / ((1 << i) * tileSize);
				heightScale = fullHeight / ((1 << i) * tileSize);
				if(max > (1 << i)) { widthScale = fullWidth / ((1 << (i + 1)) * tileSize); }
				if(max > (1 << i)) { heightScale = fullHeight / ((1 << (i + 1)) * tileSize); }
			}
			var r:uint;
			var c:uint;
			var n:uint = 1<<t;
			for(r = 0; r < n; r++) {
				if((r * tileSize) > (n * tileSize * widthScale)) {
					break;
				}
				maxTileX = r;
			}			
			for(c = 0; c < n; c++) {
				if((c * tileSize) > (n * tileSize * heightScale)) {
					break;
				}
				maxTileY = c;
			}
		}
		
		public function updateTiles(vWidth:Number, vHeight:Number, vXIS:Number, vYIS:Number, t:uint, tWidth:Number, tHeight:Number, tWInT:uint, tHInT:uint, force:Boolean = false):void {
			tierWidth = tWidth;
			
			var otX:int = tileX;
			var otY:int = tileY;
			positionCanvas();
			positionBackground(); 
			constrainPan();
			
			var currentZoom:Number = getCurrentTierScale() * (tWidth / fullWidth);
			priorBitmap.visible = ((priorTileX == tileX) && (priorTileY == tileY) && (currentZoom > priorZoom + 0.3));
			priorZoom = getCurrentTierScale() * (tWidth / fullWidth);
			
			selectTiles(vWidth, vHeight, vXIS, vYIS, t, getCurrentTierScale(), tWidth, tHeight, tWInT, tHInT);
			var moved:Boolean = ((otX != tileX) || (otY != tileY));
			if(force || moved) {
				renderUpdatedTiles();
			}
		}
		
		public function positionCanvas():void {
			var t:int;
			if(canvas.x > 0) {
				t = Math.ceil(canvas.x / (tileSize * canvas.scaleX));
				tileX -= t;
				canvas.x -= t * tileSize * canvas.scaleX;
			} else if((canvas.x + (getCanvasWidth() * canvas.scaleX)) < visWidth) {
				t = Math.ceil((visWidth - (canvas.x + getCanvasWidth() * canvas.scaleX)) / (tileSize * canvas.scaleX));
				tileX += t;
				canvas.x += t * tileSize * canvas.scaleX;
			} 
			if(canvas.y > 0) {
				t = Math.ceil(canvas.y / (tileSize * canvas.scaleY));
				tileY -= t;
				canvas.y -= t * tileSize * canvas.scaleY;
			} else if((canvas.y + (getCanvasHeight() * canvas.scaleY)) < visHeight) {
				t = Math.ceil((visHeight - (canvas.y + getCanvasHeight() * canvas.scaleY)) / (tileSize * canvas.scaleY));
				tileY += t;
				canvas.y += t * tileSize * canvas.scaleY;
			}
		}
		
		public function positionBackground():void {	
			background.x = -tileX * tileSize;
			background.y = -tileY * tileSize;
		}
				
		public function constrainPan():void {
			if(panConstrain){  
				var wd:Number = widthScale * (1 << tier) * tileSize * canvas.scaleX;
				var ht:Number = heightScale * (1 << tier) * tileSize * canvas.scaleY;
				if(wd > visWidth) {
					if(canvas.x - tileSize * tileX * canvas.scaleX > 0) {
						canvas.x = tileSize * tileX * canvas.scaleX;
						if(eventsEnabled) { dispatchEvent(new Event("viewerConstrainingPan")); }
					}
					if(canvas.x - tileSize * tileX * canvas.scaleX + wd < visWidth) {
						canvas.x = visWidth + (tileSize * tileX * canvas.scaleX) - wd;
						if(eventsEnabled) { dispatchEvent(new Event("viewerConstrainingPan")); }
					}
				} else {
					canvas.x = visWidth / 2 - wd / 2 + tileSize * tileX * canvas.scaleX;
				}
				if(ht > visHeight) {
					if(canvas.y - tileSize * tileY * canvas.scaleY > 0) {
						canvas.y = tileSize * tileY * canvas.scaleY;
						if(eventsEnabled) { dispatchEvent(new Event("viewerConstrainingPan")); }
					}
					if(canvas.y - tileSize * tileY * canvas.scaleY + ht < visHeight) {
						canvas.y = visHeight + (tileSize * tileY * canvas.scaleY) - ht;
						if(eventsEnabled) { dispatchEvent(new Event("viewerConstrainingPan")); }
					}
				} else {
					canvas.y = visHeight / 2 - ht / 2 + tileSize * tileY * canvas.scaleY;
				}
				canvas.x = Math.round(canvas.x);
				canvas.y = Math.round(canvas.y);
			}
		}
				
		public function selectTiles(vWidth:Number, vHeight:Number, vXIS:Number, vYIS:Number, t:uint, tScale:Number, tWidth:Number, tHeight:Number, tWInT:uint, tHInT:uint):void {
			if(eventsEnabled) { dispatchEvent(new Event("viewLoadingStart")); }
			var needLoad:Boolean = false;
			
			var viewLeft:Number = -(vWidth / 2);
			var viewRight:Number = vWidth / 2;
			var viewTop:Number = -(vHeight / 2);
			var viewBottom:Number = vHeight / 2;
			
			var scaledTileSize:Number = tileSize * tScale;
			var scaledCenterX:Number = (tWidth * tScale / 2) - (tWidth * tScale * (-vXIS/2));
			var scaledCenterY:Number = (tHeight * tScale / 2) - (tHeight * tScale * (-vYIS/2));
			
			var scaledLeft:Number = scaledCenterX + viewLeft;
			var scaledRight:Number = scaledCenterX + viewRight;
			var scaledTop:Number = scaledCenterY + viewTop;
			var scaledBottom:Number = scaledCenterY + viewBottom;
			
			var viewLeftColumn:Number = Math.floor(scaledLeft / scaledTileSize);
			var viewRightColumn:Number = Math.floor(scaledRight / scaledTileSize);
			var viewTopRow:Number = Math.floor(scaledTop / scaledTileSize);
			var viewBottomRow:Number = Math.floor(scaledBottom / scaledTileSize);
			
			if (viewLeftColumn < 0 || t == backgroundTier) { viewLeftColumn = 0; }
			if ((viewRightColumn > tWInT - 1) || t == backgroundTier) { viewRightColumn = tWInT - 1; }
			if (viewTopRow < 0 || t == backgroundTier) { viewTopRow = 0; }
			if ((viewBottomRow > tHInT - 1) || t == backgroundTier) { viewBottomRow = tHInT - 1; }
			
			if(!firstFullViewDrawn) { tilesToLoad = (viewRightColumn - viewLeftColumn + 1) * (viewBottomRow - viewTopRow + 1); }
			for (var rowCounter:Number = viewTopRow; rowCounter <= viewBottomRow; rowCounter++) {
				for (var columnCounter:Number = viewLeftColumn; columnCounter <= viewRightColumn; columnCounter++) {
					if(eventsEnabled) { dispatchEvent(new Event("viewLoadingProgress")); }
					if(tileCache.loadTile(tier, rowCounter, columnCounter)) {
						needLoad = true;
					}	
				}			
			}				
			if(eventsEnabled) { dispatchEvent(new Event("viewLoadingComplete")); }
			if(needLoad) {
				tileCache.purge();
			}
		}
		
		public function renderLoadedTile():void {	
			canvas.removeChild(canvasSprite);
			canvasSprite = new Sprite();
			canvas.addChildAt(canvasSprite, canvas.numChildren - hotspotsInUse);  // If not using hotspots, defaults to 0, no hotspot sprite, less children. 
			for(var r:int = tileY; r < tileY + numTilesY; r++) {
				for(var c:int = tileX; c < tileX + numTilesX; c++) {
					var idx:int = ((r - tileY) * numTilesX + (c - tileX));
					var tile:Bitmap = currentTilesArray[idx] as Bitmap; 
					var bmp:Bitmap = tileCache.convertTileDataToBitmap(tier, r, c);
					if(bmp == null || bmp.bitmapData == null) {
						currentTilesArray[idx] = null;
					} else {
						currentTilesArray[idx] = bmp;
						canvasSprite.addChild(bmp);
						bmp.smoothing = true;
						bmp.x = (c - tileX) * tileSize;
						bmp.y = (r - tileY) * tileSize;
						tilesLoaded += 1;
						if(!firstTileDrawn) {
							firstTileDrawn = true;
							dispatchEvent(new Event("viewerFirstTileDrawInternal"));
							if(eventsEnabled) { dispatchEvent(new Event("viewerFirstTileDraw")); }
						}
					}
				}
			}
			if((tilesLoaded >= tilesToLoad) && !firstFullViewDrawn && (backgroundTilesLoaded >= backgroundTilesToLoad)) { 
				firstFullViewDrawn = true;
				dispatchEvent(new Event("viewerFirstFullViewDrawInternal"));
				if(eventsEnabled) { dispatchEvent(new Event("viewerFirstFullViewDraw")); }
			}
		}

		public function renderUpdatedTiles():void {
			canvas.removeChild(canvasSprite);
			canvasSprite = new Sprite();
			canvas.addChildAt(canvasSprite, canvas.numChildren - hotspotsInUse);  // If not using hotspots, defaults to 0, no hotspot sprite, less children. 
			for(var r:int = tileY; r < tileY + numTilesY; r++) {
				for(var c:int = tileX; c < tileX + numTilesX; c++) {
					var idx:int = ((r - tileY) * numTilesX + (c - tileX));
					var tile:Bitmap = currentTilesArray[idx] as Bitmap; 
					var bmp:Bitmap = tileCache.convertTileDataToBitmap(tier, r, c);
					if(bmp == null || bmp.bitmapData == null) {
						currentTilesArray[idx] = null;
					} else {
						currentTilesArray[idx] = bmp;
						canvasSprite.addChild(bmp);
						bmp.smoothing = true;
						bmp.x = (c - tileX) * tileSize;
						bmp.y = (r - tileY) * tileSize;
						tilesLoaded += 1;
					}
				}
			}
		}
		
		public function setPriorBitmap(bmp:BitmapData):void {
			priorBitmap.bitmapData = bmp;
			priorBitmap.smoothing = true;
		}
		
		public function offsetCanvas(ox:Number, oy:Number):int {
			var xO:Number = canvas.x;
			var yO:Number = canvas.y;
			canvas.x += ox;
			canvas.y += oy;
			constrainPan();
			var r:int = 0;
			if(Math.abs(canvas.x - xO - ox) >= 1) { r |= 1; }
			if(Math.abs(canvas.y - yO - oy) >= 1) { r |= 2; }
			return r;
		}
		
		public function getImageOffset():Point {
			return new Point(
				canvas.x - tileSize * tileX * canvas.scaleX,
				canvas.y - tileSize * tileY * canvas.scaleY
			);
		}
		
		public function setImageOffset(p:Point):void {
			var ts:Number = tileSize * canvas.scaleX;
			canvas.x = Math.round(p.x + tileX * ts);
			canvas.y = Math.round(p.y + tileY * ts);
			constrainPan();
		}
		
		public function getOffset():Point {
			return new Point(
				tileSize * tileX * canvas.scaleX + -canvas.x,
				tileSize * tileY * canvas.scaleY + -canvas.y
			);
		}
		
		public function setOffset(p:Point, tWidth:Number):void {
			// Determine the correct x,y.
			var ts:Number = tileSize * canvas.scaleX;
			priorTileX = tileX = Math.floor(p.x / ts);
			priorTileY = tileY = Math.floor(p.y / ts);
			canvas.x = Math.round(-((p.x / ts) - Math.floor(p.x / ts)) * ts);
			canvas.y = Math.round(-((p.y / ts) - Math.floor(p.y / ts)) * ts);
			priorBitmap.scaleY = priorBitmap.scaleX = 1 / canvas.scaleX;
			priorBitmap.x = -canvas.x * priorBitmap.scaleX;
			priorBitmap.y = -canvas.y * priorBitmap.scaleY;
			priorBitmap.visible = true;
			background.scaleY = background.scaleX = (1 << tier) / Number(1 << backgroundTier);
			background.x = -tileX * tileSize;
			background.y = -tileY * tileSize;
		}
		
		public function getCurrentTierScale():Number {
			return canvas.scaleX;
		}

		public function resetScale(sc:Number = 1):void {
			canvas.scaleX = canvas.scaleY = sc;	
		}

		public function scaleCurrentTier(sc:Number, rx:Number, ry:Number):void {
			if(tier == 0 && sc <= 0) { sc = 1; }
			var lp:Point = new Point(rx, ry);
			lp = canvas.globalToLocal(lp);
			canvas.x += lp.x * canvas.scaleX - lp.x * sc;
			canvas.y += lp.y * canvas.scaleY - lp.y * sc;
			canvas.scaleY = canvas.scaleX = sc;
			constrainPan();
		}

		public function scaleCurrentTierRelatively(sc:Number, rx:Number, ry:Number, center:Point):void {
			if(tier == 0 && sc < 1) { sc = 1; }
			var lp:Point = new Point(rx * background.width + background.x, ry * background.height + background.y);
			center = canvas.globalToLocal(center);
			lp.x += (lp.x - center.x) * 0.5;
			lp.y += (lp.y - center.y) * 0.5;
			canvas.x += lp.x * canvas.scaleX - lp.x * sc;
			canvas.y += lp.y * canvas.scaleY - lp.y * sc;
			canvas.scaleY = canvas.scaleX = sc;
			constrainPan();
		}
				
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: EVENT HANDLERS :::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		public function tileLoaded(event:TileEvent):void {
			event.bmp.alpha = 0;
			if(event.t == backgroundTier) {
				event.loader.immortal = true;
				var bmp:Bitmap = tileCache.convertTileDataToBitmap(event.t, event.r, event.c);
				if(bmp != null) {	
					var xform:Matrix = new Matrix();
					xform.tx = event.c * tileSize;
					xform.ty = event.r * tileSize;
					background.graphics.beginBitmapFill(bmp.bitmapData, xform, false, true);
					background.graphics.drawRect(event.c * tileSize, event.r * tileSize, bmp.bitmapData.width, bmp.bitmapData.height);
					background.graphics.endFill();	
					backgroundTilesLoaded += 1;
				}
			} 
			if((tilesLoaded >= tilesToLoad) && !firstFullViewDrawn && (backgroundTilesLoaded >= backgroundTilesToLoad)) { 
				firstFullViewDrawn = true;
				dispatchEvent(new Event("viewerFirstFullViewDrawInternal"));
				if(eventsEnabled) { dispatchEvent(new Event("viewerFirstFullViewDraw")); }
			}
			if(event.t != tier) { return; }
			renderLoadedTile();
		}
		
		protected function firstTileDrawGridInternalHandler(event:Event):void {
			// Place code here to execute at scope of grid on first draw.
			removeEventListener("viewerFirstTileDrawInternal", firstTileDrawGridInternalHandler);
		}

		protected function firstFullViewDrawGridInternalHandler(event:Event):void {
			removeEventListener("viewerFirstFullViewDrawInternal", firstFullViewDrawGridInternalHandler);
			ratioBackgroundToFullWidth = background.width / (background.scaleX * fullWidth);
		}
		
		public function tileUnloaded(event:TileEvent):void {
			if(event.bmp != null) {
				for(var s:String in currentTilesArray) {
					if(currentTilesArray[s] == event.bmp) {
						currentTilesArray[s] = null;
					}
				}
				if(canvasSprite.contains(event.bmp)) {
					canvasSprite.removeChild(event.bmp);
				}
			}
		}
		
		private function fadeInTimerHandler(event:TimerEvent):void {
			for(var r:int = 0; r < numTilesY; r++) {
				for(var c:int = 0; c < numTilesX; c++) {
					var idx:int = r * numTilesX + c;
					var s:DisplayObject = currentTilesArray[idx];
					if(s == null || s.alpha == 1) { continue; }
					s.alpha += (50 / fadeInSpeed);
					if(s.alpha >= 1) {
						s.alpha = 1;
					}
				}
			}
		}
		
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::: SUPPORT METHODS ::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public function clearTiles() {
			currentTilesArray =  [];
			backgroundTier = -1;	
		}
		
		// Not currently used.  Debugging tool.
		// x value is distance of left edge of image from left edge of viewer.
		// y value is distance of left edge of image from top edge of viewer.
		// Values reported in pixels. Values do not vary with zoom.
		public function getImageOffsetInView():Point {
			var adj:Number = Math.pow(2, maxTier - tier) * canvas.scaleX;
			return new Point(
				canvas.x * adj - tileX * tileSize * adj,
				canvas.y * adj - tileY * tileSize * adj
			);
		}
		
		// Debugging tool.
		override public function toString():String {
			return (
				"fullWidth/Height: " + fullWidth + " / " + fullHeight + "\n" +
				"visWidth/Height: " + visWidth + " / " + visHeight + "\n" +
				"pixelCoords: " + Math.round(x) + " / " + Math.round(y) + "\n" +
				"tilePos: " + tileX + " / " + tileY + "\n" +
				"tileSize: " + tileSize + "\n" +
				"canvasCoords: " + canvas.x + " / " + canvas.y + "\n" +
				"canvasScale: " + canvas.scaleX + "\n" + 
				"canvasSize: " + Math.round((1 << tier) * tileSize) + " / " + Math.round((1 << tier) * tileSize) + "\n" + 
				"tier: " + tier + "\n" +
				"maxtier: " + maxTier + "\n"
			);
		}		
					
		protected function indexOfContainingElement(arrayToFindIn:Array, elementToFind:String):Number {
			var elementIndex:Number = -1;
			var elmntCntr:Number = 0;
			var arrayLength:Number = arrayToFindIn.length;
			while(elmntCntr < arrayLength) {				
				if(arrayToFindIn[elmntCntr].toString().indexOf(elementToFind) != -1) {
					elementIndex = elmntCntr;
					elmntCntr = arrayLength;
				}else{
					elmntCntr++;
				}
			}
			return elementIndex;
		}
	}
}