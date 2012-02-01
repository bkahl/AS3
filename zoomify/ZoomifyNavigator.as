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

package zoomify
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import fl.core.UIComponent;
	import fl.core.InvalidationType;
	import fl.managers.IFocusManagerComponent;
	import zoomify.IZoomifyViewer;
	import zoomify.viewer.TileCache;
	import zoomify.events.TileEvent;
	import zoomify.utils.Resources;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

    
	//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	//:::::::::::::::::::::::::::::::::::::::: STYLES ::::::::::::::::::::::::::::::::::::::::
	//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

	/**
	 * Style description background
	 *
	 * @default ZoomifyNavigator_background
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.28.0
	 */
	[Style(name="background", type="Class")]

	/**
	 * Style description thumbRect
	 *
	 * @default ZoomifyNavigator_thumbRect
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.28.0
	 */
	[Style(name="thumbRect", type="Class")]


	public class ZoomifyNavigator extends UIComponent implements IFocusManagerComponent
	{				
		
	
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: INIT METHODS :::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		protected var content:Sprite;
		protected var contentScrollRect:Rectangle;
		protected var background:DisplayObject;
		protected var bitmap:Sprite;
		protected var rect:Sprite;
		protected var bg:Bitmap;
		protected var hit:Point;

		protected var _viewer:IZoomifyViewer;
		protected var _tileCache:TileCache;
		protected var _sizeToFit:String;
		protected var navInitTimer:Timer = new Timer(0,0);
		
		/**
		 * @private
		 */
		private static var defaultStyles:Object = {
			background: "ZoomifyNavigator_background",
			thumbRect: "ZoomifyNavigator_thumbRect"
		};

		public static function getStyleDefinition():Object { return defaultStyles; }


		/**
		 * Creates a new ZoomifyNavigator component instance.
		 */
		public function ZoomifyNavigator():void
		{
			super();
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}

		/**
		 * @private (protected)
		 */
		override protected function configUI():void {
			super.configUI();

			background = getDisplayObjectInstance(getStyleValue("background"));
			addChild(background);

			contentScrollRect = new Rectangle(0, 0, 100, 100);
			content = new Sprite();
			content.visible = false;
			content.x = 1;
			content.y = 1;
			content.scrollRect = contentScrollRect;
			addChild(content);
			
			bitmap = new Sprite();
			content.addChild(bitmap);
			
			var thumbRect:DisplayObject = getDisplayObjectInstance(getStyleValue("thumbRect"));
			rect = new Sprite();
			rect.visible = false;
			rect.buttonMode = true;
			rect.useHandCursor = true;
			rect.addChild(thumbRect);
			content.addChild(rect);
			
			visible = false;
		}
		
		/**
		 * @private (protected)
		 */
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				var backgroundSkin:DisplayObject = getDisplayObjectInstance(getStyleValue("background"));
				if(background != backgroundSkin) {
					swapDisplayObjects(background, backgroundSkin);
					background = backgroundSkin;
				}
			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			super.draw();
		}
		
		/**
		 * @private (protected)
		 */
		protected function swapDisplayObjects(oldDO:DisplayObject, newDO:DisplayObject):void {
			try {
				var idx:int = getChildIndex(oldDO);
				removeChildAt(idx);
				addChildAt(newDO, idx);
				invalidate(InvalidationType.SIZE);
			}
			catch(e:Error) {
			}
		}
		
		/**
		 * @private (protected)
		 */
		protected function drawLayout():void {
			background.width = width - 1;
			background.height = height - 1;
			contentScrollRect = content.scrollRect;
			contentScrollRect.width = width - 2;
			contentScrollRect.height = height - 2;
			content.scrollRect = contentScrollRect;
			visible = true;
		}		
		
		

		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::: GET & SET METHODS ::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public function get viewer():IZoomifyViewer {
			return _viewer;
		}

		public function set viewer(value:IZoomifyViewer):void {
			if (_viewer != null) {
				_viewer.removeEventListener("viewerInitializationCompleteInternal", viewerInitializationCompleteInternalHandler);
				_viewer.removeEventListener("areaChanged", viewerAreaChangedHandler);
			}
			_viewer = value;
			if (_viewer != null) {
				_viewer.addEventListener("viewerInitializationCompleteInternal", viewerInitializationCompleteInternalHandler, false, 0, true);
				_viewer.addEventListener("areaChanged", viewerAreaChangedHandler, false, 0, true);
				_viewer.addEventListener("imageChangedInternal", viewerImageChangedInternalHandler, false, 0, true);
			}	
		}

		[Inspectable(defaultValue="")]
		public function get viewerName():String {
			return _viewer.name;
		}

		public function set viewerName(value:String):void {
			try {
				viewer = parent.getChildByName(value) as IZoomifyViewer;
			} catch (error:Error) {
				throw new Error(Resources.ERROR_SETTINGVIEWER);
			}
		}	

		[Inspectable(defaultValue="useHeightAndWidth", type="list", enumeration="sizeToFitViewer, sizeToFitImage, useHeightAndWidth")]
		public function get sizeToFit():String {
			return _sizeToFit;
		}

		public function set sizeToFit(value:String):void {
			switch (value) {
				case "-0" : 
					_sizeToFit = "-0";
					break;
				case "-1" : 
					_sizeToFit = "-1";
					break;
				case "sizeToFitViewer" : 
					_sizeToFit = "-0";
					break;
				case "sizeToFitImage" :
					_sizeToFit = "-1";
					break;
				default :
					_sizeToFit = "";
			}
		}



		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::: STARTUP METHODS ::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		/**
		 * @private (protected)
		 */
		protected function viewerInitializationCompleteInternalHandler(event:Event = null):void {
			rect.visible = true;
			content.visible = true;
			var tile:Bitmap = _viewer.tileCache.convertTileDataToBitmap(0, 0, 0);
			if(tile != null) {
				bg = tile;
				bitmap.x = bitmap.y = 0;
				bitmap.scaleX = bitmap.scaleY = 1;
				bitmap.graphics.clear();
				bitmap.graphics.beginBitmapFill(tile.bitmapData, null, false, true);
				bitmap.graphics.drawRect(0, 0, tile.bitmapData.width, tile.bitmapData.height);
				bitmap.graphics.endFill();
				if(_sizeToFit == "-1"){
					sizeNavigatorToFitImage();
				}else if(_sizeToFit == "-0"){
					sizeNavigatorToFitViewer();				
				}
				renderNavigatorThumbnail();
			} else {
				navInitTimer = new Timer(500, 1);
				navInitTimer.addEventListener("timer", navInitTimerHandler, false, 0, true);
				navInitTimer.start();
			}
		}
				
		protected function navInitTimerHandler(event:TimerEvent):void {
			if(navInitTimer.running) { 
				navInitTimer.stop(); 
				navInitTimer.removeEventListener("timer", navInitTimerHandler);
			}
			viewerInitializationCompleteInternalHandler();
		}
		
		/**
		 * @private (protected)
		 */
		public function sizeNavigatorToFitImage():void {
			height = width;
			var imageAspectRatio:Number = bitmap.width / bitmap.height;
			if(imageAspectRatio > 1){
				height /= imageAspectRatio;
			}else if(imageAspectRatio < 1){
				width *= imageAspectRatio;
			}
		}
		
		/**
		 * @private (protected)
		 */
		public function sizeNavigatorToFitViewer():void {
			height = width;
			var viewerAspectRatio:Number = _viewer.width / _viewer.height;
			if(viewerAspectRatio > 1){
				height /= viewerAspectRatio;
			}else if(viewerAspectRatio < 1){
				width *= viewerAspectRatio;
			}
		}

		
		/**
		 * @private (protected)
		 */
		protected function renderNavigatorThumbnail():void {			
			var navDispW:Number = width - 2;
			var navDispH:Number = height - 2;
			var scaleW:Number = navDispW / bitmap.width;
			var scaleH:Number = navDispH / bitmap.height;			
			if(_sizeToFit == "-1"){
				bitmap.width = width - 2;
				bitmap.height = height - 2;
				bitmap.x = 0;
				bitmap.y = 0;
			} else if(scaleW == scaleH) {
				bitmap.scaleX = bitmap.scaleY = scaleW;
			} else if(scaleW < scaleH) {
				bitmap.scaleX = bitmap.scaleY = scaleW;
				bitmap.y = ((navDispH - bitmap.height * (navDispW / bitmap.width)) / 2);
			} else if(scaleW > scaleH) {
				bitmap.scaleX = bitmap.scaleY = scaleH;
				bitmap.x = ((navDispW - bitmap.width * (navDispH / bitmap.height)) / 2);
			}
		}
		
		/**
        	 * @private (protected)
		 */
		protected function viewerImageChangedInternalHandler(event:Event):void {  
			var tile:Bitmap = _viewer.tileCache.convertTileDataToBitmap(0, 0, 0);
			if(tile != null) {
				bg = tile;
				bitmap.x = bitmap.y = 0;
				bitmap.scaleX = bitmap.scaleY = 1;
				bitmap.graphics.clear();
				bitmap.graphics.beginBitmapFill(tile.bitmapData, null, false, true);
				bitmap.graphics.drawRect(0, 0, tile.bitmapData.width, tile.bitmapData.height);
				bitmap.graphics.endFill();
				if(_sizeToFit == "-1"){
					sizeNavigatorToFitImage();
				}else if(_sizeToFit == "-0"){
					sizeNavigatorToFitViewer();				
				}
				renderNavigatorThumbnail();
			}
		}
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::: CORE METHODS :::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		/**
		 * @private (protected)
		 */
		protected function adjustPosition():void {
			_viewer.setExternalPanningFlag(true);
			rect.x = Math.min(Math.max(-1, mouseX - hit.x), content.width - rect.width);
			rect.y = Math.min(Math.max(-1, mouseY - hit.y), content.height - rect.height);
			var scale:Number = _viewer.getZoomDecimal();
			var offset:Point = new Point();
			offset.x = -((rect.x + 1 - bitmap.x) * _viewer.imageWidth * scale / bitmap.width);
			offset.y = -((rect.y + 1 - bitmap.y) * _viewer.imageHeight * scale / bitmap.height);
			_viewer.setImageOffset(offset);
		}
		
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: EVENT HANDLERS :::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		/**
		 * @private (protected)
		 */
		protected function mouseDownHandler(event:MouseEvent):void {
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("navigatorMouseDown")); }
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			if(rect.hitTestPoint(stage.mouseX, stage.mouseY)) {
				hit = new Point(mouseX - rect.x, mouseY - rect.y);
			} else {
				hit = new Point(rect.width / 2, rect.height / 2);
				adjustPosition();
			}
		}

		/**
		 * @private (protected)
		 */
		protected function mouseMoveHandler(event:MouseEvent):void {
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("navigatorMouseMove")); }
			adjustPosition();
		}

		/**
		 * @private (protected)
		 */
		protected function mouseUpHandler(event:MouseEvent):void {
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("navigatorMouseUp")); }
			_viewer.setExternalPanningFlag(false);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_viewer.invalidate(InvalidationType.STATE);
		}
		
		/**
        	 * @private (protected)
		 */
		protected function viewerAreaChangedHandler(event:Event):void {
			var visWidth:Number = _viewer.width;
			var visHeight:Number = _viewer.height;
			var scale:Number = _viewer.getZoomDecimal();
			var offset:Point = _viewer.getImageOffset();
			rect.x = -offset.x * bitmap.width / (_viewer.imageWidth * scale) + bitmap.x - 1;
			rect.y = -offset.y * bitmap.height / (_viewer.imageHeight * scale) + bitmap.y - 1;
			rect.width = visWidth * bitmap.width / (_viewer.imageWidth * scale) + 1;
			rect.height = visHeight * bitmap.height / (_viewer.imageHeight * scale) + 1;
		}
	}
}