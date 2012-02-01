//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
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
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.ui.Keyboard;
	import fl.core.UIComponent;
	import fl.core.InvalidationType;
	import fl.managers.IFocusManagerComponent;
	import zoomify.IZoomifyViewer;
	import zoomify.events.TileProgressEvent;
	import zoomify.viewer.ZoomGrid;
	import zoomify.viewer.TileCache;
	import zoomify.viewer.SplashScreen;
	import zoomify.viewer.MessageScreen;
	import zoomify.utils.Tooltip;
	import zoomify.utils.Resources;


	//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	//:::::::::::::::::::::::::::::::::::::::: STYLES ::::::::::::::::::::::::::::::::::::::::
	//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

	/**
	 * Style description splashScreenLogo
	 *
	 * @default ZoomifyViewer_splashScreenLogo
	 */
	[Style(name="splashScreen", type="Class")]
	
	
	/**
	 * Style description messageScreenLogo
	 *
	 * @default ZoomifyViewer_messageScreenLogo
	 */
	[Style(name="messageScreen", type="Class")]

	/**
	 * Style description tooltipBackground
	 *
	 * @default ZoomifyViewer_tooltipBackground
	 */
	[Style(name="tooltipBackground", type="Class")]


	public class ZoomifyViewer extends UIComponent implements IFocusManagerComponent, IZoomifyViewer
	{
	
	
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: INIT METHODS :::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		protected var content:MovieClip;
		protected var contentScrollRect:Rectangle;
		protected var grid:ZoomGrid;
				
		protected var logoSplashScreen:Sprite;
		protected var textMessageScreen:Sprite;

		protected var _initialized:Boolean = false;
		protected var _imagePath:String;
		protected var changingImage = false;
		protected var _tierScaleUpThreshold:Number = 1.15;
		protected var _tierScaleDownThreshold:Number = _tierScaleUpThreshold/2; 
		/* Dev Note: quality scaling-down exceeds that of scaling-up, however, both are limited. 
		   Permitting slight scale-up of non-full-resolution tiers provides most consistent overall 
		   quality. Scale-down threshold is scale up threshold / 2 because 1 / scale-up threshold 
		   inversion would cause overlap of ascending and descending scales as tiers are 
		   powers of 2. */
		protected var _keyboardEnabled:Boolean = true;
		protected var _splashScreenVisibility:Boolean = true;
		protected var _clickZoom:Boolean = true;
		protected var _zoomSpeed:Number = 10;
		protected var _fadeInSpeed:Number = 200;
		protected var _panConstrain:Boolean = true;
		protected var _eventsEnabled:Boolean = false;
		
		protected var _viewX:Number;
		protected var _viewY:Number;
		protected var _viewZoom:Number;
		
		protected var _messageScreenVisibility:Boolean = false;
		protected var _tileCache:TileCache;
		
		protected	var zoomSpeedAdj:Number = _zoomSpeed * 1.25;
		protected	var zoomFactor:Number = 1 / (1000 / (zoomSpeedAdj * zoomSpeedAdj));
		
		protected var _imageWidth:Number;
		protected var _imageHeight:Number;
		protected var _imageTileSize:Number;

		protected var _initialX:Number = 0;
		protected var _initialY:Number = 0;
		protected var _initialZoom:Number = -1;
		protected var _minZoom:Number = -1;
		protected var _maxZoom:Number = 100;
		
		protected var minZoomDecimal:Number = 10 / 100; // Temp value. Cannot calc zoomToFit decimal value before grid exists.
		protected var maxZoomDecimal:Number = _maxZoom / 100;

		protected var targetZoomDecimal:Number = 0;
		protected var targetPanX:Number = 0;
		protected var targetPanY:Number = 0;
		
		protected var toolbarZoomFlag:Number = 0;
		protected var toolbarHorizontalFlag:Number = 0;
		protected var toolbarVerticalFlag:Number = 0;

		protected var cachedView1:BitmapData;
		protected var cachedView2:BitmapData;
		protected var currentCacheView:BitmapData;

		public var currentTier:int = 0;
		public var tierWidthsArray:Array =  [];
		public var tierHeightsArray:Array =  [];
		public var tierWidthsInTilesArray:Array =  [];
		public var tierHeightsInTilesArray:Array =  [];
		
		protected var numTiers:uint = 0;
		protected var currentTierScale:Number = 1;
		protected var spaceZooming:Boolean = false;
		protected var scaleCalc:Number;
		protected var hit:Point;
		protected var lastMouse:Point;
		protected var zoomPoint:Point;	

		protected var updateTierTimer:Timer;
		protected var ignoreMouseUp:Boolean = true;
		protected var mouseIsDown:Boolean = false;
		protected var viewPanning:Boolean = false;
		protected var externalPanning:Boolean = false;
		protected var viewZooming:Boolean = false;	
		protected var externalZooming:Boolean = false;
		
		protected var dragged:Boolean = false;
		
		protected var tmpXParam:String = "center";
		protected var tmpYParam:String = "center";	
		protected var tmpX:Number = 0;
		protected var tmpY:Number = 0;
		protected var tmpZoom:Number = -1;		
			
		protected var zoomToViewTimer:Timer = new Timer(0,0);
		protected var changeXStart:Number;
		protected var changeYStart:Number;
		protected var changeCurrentTierScaleStart:Number;
		protected var changeXSpan:Number;
		protected var changeYSpan:Number;
		protected var changeCurrentTierScaleSpan:Number;

		public var errFileNotFound = Resources.ERROR_LOADINGFILE+"%s";
		
		/**
		 * @private
		 *
		 * @langversion 3.0
		 * @playerversion Flash 9.0.28.0
		 */
		private static var defaultStyles:Object = {
			splashScreen: "zoomify.viewer.SplashScreen",
			messageScreen: "zoomify.viewer.MessageScreen",
			tooltipBackground: "ZoomifyViewer_tooltipBackground"
		};

		/**
		 * 
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 9.0.28.0
		 */
		public static function getStyleDefinition():Object { return defaultStyles; }


		/**
		 * Creates a new ZoomifyViewer component instance.
		 *
		 * @langversion 3.0
		 * @playerversion Flash 9.0.28.0
		 */
		public function ZoomifyViewer():void
		{
			super();
			tabEnabled = false;
			
			_tileCache = new TileCache();
			_tileCache.addEventListener(TileProgressEvent.TILE_PROGRESS, tileProgressHandler);
			
			updateTierTimer = new Timer(300, 1);
			updateTierTimer.addEventListener("timer", updateTierTimerHandler, false, 0, true);

			// Scale up threshold must not be less than or equal to 1 or greater than 2.
			if(_tierScaleUpThreshold <= 1 || _tierScaleUpThreshold > 2) {
				_tierScaleUpThreshold = 1.15;
				_tierScaleDownThreshold = 1/_tierScaleUpThreshold;
			}
			
			lastMouse = new Point(mouseX, mouseY);

			addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);

			initializeStageKeyboardListeners();
			initializeStageMouseListeners();
			initializeTooltip();
		}
				
		/**
		 * @private (protected)
		 */
		protected function loadImageProperties():void {
			if(_imagePath == null || _imagePath == "") { return; } 
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadImagePropertiesCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadImagePropertiesIOErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadImagePropertiesIOErrorHandler);
			tileCache.setPath(_imagePath);
			loader.load(new URLRequest(_imagePath + "/" + "ImageProperties.xml"));
		}
				
		/**
		 * @private (protected)
		 */
		protected function loadImagePropertiesCompleteHandler(event:Event):void {
			if(_eventsEnabled) { dispatchEvent(new Event("imagePropertiesLoadingComplete")); }
			var loader:URLLoader = event.target as URLLoader;
			var xml:XML = new XML(loader.data);
			
			// Determine max tier.
			_imageWidth = uint(xml.@WIDTH);
			_imageHeight = uint(xml.@HEIGHT);
			_imageTileSize = int(xml.@TILESIZE);
			
			calculateTierValues();
			cachedView1 = new BitmapData(Math.ceil(width), Math.ceil(height), true, 0);
			cachedView2 = new BitmapData(Math.ceil(width), Math.ceil(height), true, 0);
			currentCacheView = cachedView1;
			tileCache.calculatePathLimits(imageTileSize, imageWidth, imageHeight);
			
			var container:Sprite = new Sprite();
			content.addChild(container);
			grid = new ZoomGrid(container, tileCache);
			
			grid.active(false);
			grid.viewer = this;
			grid.setMaxTier(numTiers - 1);	
			grid.addEventListener("viewerFirstTileDrawInternal", firstTileDrawViewerInternalHandler, false, 0, true);
			grid.addEventListener("viewerFirstFullViewDrawInternal", firstFullViewDrawViewerInternalHandler, false, 0, true);
			grid.configureCanvas(imageTileSize, width, height, imageWidth, imageHeight, 0, _tierScaleDownThreshold, tierWidthsInTilesArray, tierHeightsInTilesArray);
			calcZoomConstraints();
			grid.setFadeInSpeed(_fadeInSpeed);
			grid.setPanConstrain(_panConstrain);	
			_initialX = tmpX = (!isNaN(parseFloat(tmpXParam))) ? parseFloat(tmpXParam) : (imageWidth / 2);
			_initialY = tmpY = (!isNaN(parseFloat(tmpYParam))) ? parseFloat(tmpYParam) : (imageHeight / 2);
			setView(tmpX, tmpY, tmpZoom);
			grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), currentTier, tierWidthsArray[currentTier], tierHeightsArray[currentTier], tierWidthsInTilesArray[currentTier], tierHeightsInTilesArray[currentTier], false);
			grid.active(true); 	
			
			invalidate(InvalidationType.SIZE); 
			invalidate(InvalidationType.STATE); 
		}
		
		/**
		 * @private (protected)
		 */
		protected function loadImagePropertiesIOErrorHandler(event:Event):void {
			var isLivePreview:Boolean = (parent != null && getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent");
			if(isLivePreview && _imagePath != null && _imagePath != "") { 
				showMessage(Resources.ALERT_IMAGELIVEPREVIEW + _imagePath); 
				return;
			}	
			dispatchEvent(new Event("imagePropertiesLoadingFailedInternal"));
			if(_eventsEnabled) { dispatchEvent(new Event("imagePropertiesLoadingFailed")); }
			var imagePathClean:String = _imagePath;
			if(imagePathClean.slice(0, 1) == '/') { imagePathClean = imagePathClean.slice(1, imagePathClean.length); }
			showMessage(errFileNotFound.split("%s").join(imagePathClean));
 		}
		
		/**
		 * @private (protected)
		 */ 		
 		private function calculateTierValues():void {
			tierWidthsArray =  [];
			tierHeightsArray =  [];
			tierWidthsInTilesArray =  [];
			tierHeightsInTilesArray =  [];
 			var max:Number = Math.max(imageWidth, imageHeight) / Number(imageTileSize);
			for(var i:uint = 0; (1 << i) <= max; i++) {
				numTiers = i + 1;
				if(max > (1 << i)) { numTiers += 1; }
			}
 			var tempWidth:Number = imageWidth;
			var tempHeight:Number = imageHeight;
			for(var t:int = numTiers - 1; t >= 0; t--) {
				tierWidthsArray[t] = tempWidth;
				tierHeightsArray[t] = tempHeight;	
				tierWidthsInTilesArray[t] = (tempWidth % imageTileSize) ? Math.floor(tempWidth / imageTileSize) + 1 : Math.floor(tempWidth / imageTileSize);
				tierHeightsInTilesArray[t] = (tempHeight % imageTileSize) ? Math.floor(tempHeight / imageTileSize) + 1 : Math.floor(tempHeight / imageTileSize);
				tempWidth = Math.floor(tempWidth / 2);
				tempHeight = Math.floor(tempHeight / 2);
			}
		}
		
		/**
		 * @private (protected)
		 */
		protected function firstTileDrawViewerInternalHandler(event:Event):void {
			grid.removeEventListener("viewerFirstTileDrawInternal", firstTileDrawViewerInternalHandler);
			this.splashScreenVisibility = false; // Hide splashscreen before first tile displays.
			cacheView(); // Recapture initial view bitmap without splashscreen logo.
		}
		
		/**
		 * @private (protected)
		 */
		protected function firstFullViewDrawViewerInternalHandler(event:Event):void {
			removeEventListener("viewerFirstFullViewDrawInternal", firstFullViewDrawViewerInternalHandler);
			content.visible = true;
			invalidate(InvalidationType.SIZE);
			_initialized = true;
			if(changingImage == false) {
				dispatchEvent(new Event("imageChangedInternal"));
				dispatchEvent(new Event("viewerInitializationCompleteInternal"));
				if(_eventsEnabled) { dispatchEvent(new Event("viewerInitializationComplete")); }
			} else {
				dispatchEvent(new Event("imageChangedInternal"));
				dispatchEvent(new Event("imageChanged")); 
			}
			dispatchEvent(new Event("areaChanged"));
		}

		/**
		 * @private (protected)
		 */
		override protected function configUI():void {
			super.configUI();	
			configLogoSplashScreen();
			configScrollRect();
			configTextMessageScreen();
		}
						
		/**
		 * @private (protected)
		 */
		protected function configLogoSplashScreen():void {
			var splashScreenSkin:DisplayObject = getDisplayObjectInstance(getStyleValue("splashScreen"));
			logoSplashScreen = new Sprite();
			logoSplashScreen.visible = false;
			_splashScreenVisibility = logoSplashScreen.visible;			
			logoSplashScreen.buttonMode = true;
			logoSplashScreen.addChild(splashScreenSkin);
			logoSplashScreen.addEventListener(MouseEvent.CLICK, splashScreenClickHandler, false, 0, true);
			addChild(logoSplashScreen);
		}
								
		/**
		 * @private (protected)
		 */
		protected function configScrollRect():void {
			contentScrollRect = new Rectangle(0, 0, 100, 100);
			content = new MovieClip();
			content.visible = false;
			content.scrollRect = contentScrollRect;
			addChild(content);
		}

		/**
		 * @private (protected)
		 */
		protected function configTextMessageScreen():void {
			var textMessageScreenSkin:DisplayObject = getDisplayObjectInstance(getStyleValue("messageScreen"));
			textMessageScreen = new Sprite();
			textMessageScreen.visible = false;
			_messageScreenVisibility = textMessageScreen.visible;
			textMessageScreen.buttonMode = true;
			textMessageScreen.addChild(textMessageScreenSkin);
			textMessageScreen.addEventListener(MouseEvent.CLICK, messageScreenClickHandler, false, 0, true);
			addChild(textMessageScreen);
		}
		
		/**
		 * @private
		 */
		private function initializeStageKeyboardListeners(event:Event = null):void {
			if(stage == null) {
				// Wait for stage to initialize.
				addEventListener(Event.ADDED_TO_STAGE, initializeStageKeyboardListeners, false, 0, true);
			} else {
				removeEventListener(Event.ADDED_TO_STAGE, initializeStageKeyboardListeners);
				if(enabled && _keyboardEnabled) {
					stage.addEventListener(KeyboardEvent.KEY_UP, stageKeyUpHandler, false, 0, true);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler, false, 0, true);
				} else {
					stage.removeEventListener(KeyboardEvent.KEY_UP, stageKeyUpHandler);
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler);
				}
			}
		}

		/**
		 * @private
		 */
		private function initializeStageMouseListeners(event:Event = null):void {
			if(stage == null) {
				// Wait for stage to initialize.
				addEventListener(Event.ADDED_TO_STAGE, initializeStageMouseListeners, false, 0, true);
			} else {
				removeEventListener(Event.ADDED_TO_STAGE, initializeStageMouseListeners);
				if(enabled && mouseEnabled) {
					stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, false, 0, true);
					stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler, false, 0, true);
					stage.addEventListener(MouseEvent.MOUSE_WHEEL, stageMouseWheelHandler, false, 0, true);
					addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
					addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
				} else {
					stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, stageMouseWheelHandler);
					removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
					removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				}
			}
		}
		
		public function getTooltipBackground():DisplayObject {
			return getDisplayObjectInstance(getStyleValue("tooltipBackground"));
		}
		
		/**
		 * @private
		 */
		private function initializeTooltip(event:Event = null):void {
			if(stage == null) {
				// Wait for stage to initialize.
				addEventListener(Event.ADDED_TO_STAGE, initializeTooltip, false, 0, true);
			} else {
				removeEventListener(Event.ADDED_TO_STAGE, initializeTooltip);
				Tooltip.initialize(this);
			}
		}
		
		
		
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::: GET & SET METHODS ::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public function get initialized():Boolean {
			return _initialized;
		}
		
		public function set initialized(value:Boolean):void {
			_initialized = value;
		}
		
		[Inspectable(defaultValue="")]
		public function get imagePath():String {
			return _imagePath;
		}
		
		public function set imagePath(value:String):void {
			if(_imagePath == value) { return };
			if(_imagePath != null) {
				hideMessage();
				if(grid != null) { clearAll(); }
				changingImage = true;
				addEventListener("imageChangedInternal", viewerImageChangedInternalHandler, false, 0, true);
			}
			_imagePath = value;
			loadImageProperties();
		}
		
		/**
        	 * @private (protected)
		 */
		protected function viewerImageChangedInternalHandler(event:Event):void {
			setInitialView();
		}
		
		public function get viewX():Number {
			if(grid) {
				return grid.x;
			} else {
				return 0;
			}
		}
		
		public function set viewX(x:Number):void {
			if(grid) {
				_viewX = x;
				grid.x = _viewX;
				invalidate(InvalidationType.STATE);
			} else {
				tmpX = x;
			}
		}
		
		public function get viewY():Number {
			if(grid) {
				return grid.y;
			} else {
				return 0;
			}
		}
		
		public function set viewY(y:Number):void {
			if(grid) {
				_viewY = y;
				grid.y = _viewY;
				invalidate(InvalidationType.STATE);
			} else {
				tmpY = y;
			}
		}
		
		public function getViewXImageSpan():Number {
			if(grid) {
				return grid.xImageSpan;
			} else {
				return 0;
			}
		}
		
		public function setViewXImageSpan(x:Number):void {
			if(grid) {
				grid.xImageSpan = x;
				invalidate(InvalidationType.STATE);
			} else {
				tmpX = x;
			}
		}
		
		public function getViewYImageSpan():Number {
			if(grid) {
				return grid.yImageSpan;
			} else {
				return 0;
			}
		}
		
		public function setViewYImageSpan(y:Number):void {
			if(grid) {
				grid.yImageSpan = y;
				invalidate(InvalidationType.STATE);
			} else {
				tmpY = y;
			}
		}
		
		public function get viewZoom():Number {
			if(grid) {
				return getZoomDecimal() * 100;
			} else {
				return 0;
			}
		}
		
		public function set viewZoom(targetZoom:Number):void {
			if(grid) {
				var zoomDecimalCalc:Number;
				if(targetZoom != -1) {
					zoomDecimalCalc = convertZoomPercentToDecimal(targetZoom);
				} else {
					zoomDecimalCalc = calcZoomDecimalToFitDisplay();
				}
				if(zoomDecimalCalc < minZoomDecimal) { zoomDecimalCalc = minZoomDecimal; }
				if(zoomDecimalCalc > maxZoomDecimal) { zoomDecimalCalc = maxZoomDecimal; }
				_viewZoom = zoomDecimalCalc;
				setZoomDecimal(_viewZoom);
				invalidate(InvalidationType.STATE);
			} else {
				tmpZoom = targetZoom;
			}
		}
		
		public function setZoomDecimal(sc:Number, dispatchScaleEvent:Boolean = true):void {
			sc *= (1 << (numTiers - 1)); 
			modifyCurrentTierScale((sc / (1 << grid.getCurrentTier())) - currentTierScale, new Point(width / 2, height / 2), dispatchScaleEvent);
		}

		public function getZoomDecimal():Number {
			return currentTierScale * (getTierWidth(grid.getCurrentTier()) / imageWidth);
		}
		
		[Inspectable(defaultValue="center")]
		public function get initialX():String {
			return _initialX.toString();
		}

		public function set initialX(x:String):void {
			_initialX = (!isNaN(parseFloat(x))) ? parseFloat(x) : 0;
			if(grid) {	
				if(x == "center") { _initialX = imageWidth / 2; }
			} else {
				tmpXParam = x;
			}
		}

		[Inspectable(defaultValue="center")]
		public function get initialY():String {
			return _initialY.toString();
		}

		public function set initialY(y:String):void {
			_initialY = (!isNaN(parseFloat(y))) ? parseFloat(y) : 0;
			if(grid) {	
				if(y == "center") { _initialY = imageHeight / 2; }
			} else {
				tmpYParam = y;
			}
		}
		
		[Inspectable(defaultValue="-1")]
		public function get initialZoom():Number {
			return _initialZoom;
		}
		
		public function set initialZoom(zoom:Number):void {
			_initialZoom = zoom;
			if(grid == null) { tmpZoom = _initialZoom; }
		}
		
		[Inspectable(defaultValue="-1")]
		public function get minZoom():Number {
			return _minZoom;
		}
		
		public function set minZoom(minZoom:Number):void {
			_minZoom = minZoom;
			if(grid){ minZoomDecimal = convertZoomPercentToDecimal(_minZoom); }
		}
		
		[Inspectable(defaultValue="100")]
		public function get maxZoom():Number {
			return _maxZoom;
		}
		
		public function set maxZoom(maxZoom:Number):void {
			_maxZoom = maxZoom;
			if(grid){ maxZoomDecimal = convertZoomPercentToDecimal(_maxZoom); }
		}
				
		public function getMinimumZoomDecimal():Number {
			return convertZoomPercentToDecimal(_minZoom);
		}
		
		public function getMaximumZoomDecimal():Number {
			return convertZoomPercentToDecimal(_maxZoom);
		}

		[Inspectable(defaultValue="true")]
		public function get splashScreenVisibility():Boolean {
			return _splashScreenVisibility;
		}
		
		public function set splashScreenVisibility(value:Boolean):void {
			logoSplashScreen.visible = value;
			_splashScreenVisibility = logoSplashScreen.visible;
		}

		[Inspectable(defaultValue="true")]
		public function get clickZoom():Boolean {
			return _clickZoom;
		}
		
		public function set clickZoom(value:Boolean):void {
			_clickZoom = value;
		}
		
		[Inspectable(defaultValue="10")]
		public function get zoomSpeed():Number {
			return _zoomSpeed;
		}
		
		public function set zoomSpeed(speedSetting:Number):void {
			_zoomSpeed = Math.max(1, Math.min(50, speedSetting));
			zoomSpeedAdj = _zoomSpeed * 1.25;
			zoomFactor = 1 / (1000 / (zoomSpeedAdj * zoomSpeedAdj));
		}

		[Inspectable(defaultValue="150")]
		public function get fadeInSpeed():Number {
			return _fadeInSpeed;
		}
		
		public function set fadeInSpeed(durationInMilliseconds:Number):void {
			if(durationInMilliseconds < 1) { durationInMilliseconds = 1; }
			_fadeInSpeed = durationInMilliseconds;
			if(grid != null) {
				grid.setFadeInSpeed(_fadeInSpeed);
			}
		}
		
		[Inspectable(defaultValue="true")]
		public function get panConstrain():Boolean {
			return _panConstrain;
		}
		
		public function set panConstrain(value:Boolean):void {
			_panConstrain = value;
			if(grid != null) {
				grid.setPanConstrain(_panConstrain);
			}
		}

		[Inspectable(defaultValue="false")]
		public function get eventsEnabled():Boolean {
			return _eventsEnabled;
		}
		
		public function set eventsEnabled(value:Boolean):void {
			_eventsEnabled = value;
			if(grid != null) {
				grid.setEventsEnabled(_eventsEnabled);
			}
		}
		
		[Inspectable(defaultValue="true")]
		override public function get enabled():Boolean {
			return super.enabled;
		}
		
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			if(grid) { grid.enabled = value; }
			initializeStageKeyboardListeners();
			initializeStageMouseListeners();
		}

		[Inspectable(defaultValue="true")]
		override public function get mouseEnabled():Boolean {
			return super.mouseEnabled;
		}
		
		override public function set mouseEnabled(value:Boolean):void {
			super.mouseEnabled = value;
			if(grid) { grid.enabled = value; }
			initializeStageMouseListeners();
		}

		[Inspectable(defaultValue="true")]
		public function get keyboardEnabled():Boolean {
			return _keyboardEnabled;
		}
		
		public function set keyboardEnabled(value:Boolean):void {
			_keyboardEnabled = value;
			initializeStageKeyboardListeners();
		}
				
		public function get messageScreenVisibility():Boolean {
			return _messageScreenVisibility;
		}

		public function set messageScreenVisibility(value:Boolean):void {
			textMessageScreen.visible = value;
			_messageScreenVisibility = textMessageScreen.visible;
		}
		
		public function setExternalPanningFlag(value:Boolean): void {
			externalPanning = value;
		}
		
		public function setExternalZoomingFlag(value:Boolean): void {
			externalZooming = value;
		}

		public function get tileCache():TileCache {
			return _tileCache;
		}
		
		public function get zoomGrid():ZoomGrid {
			return grid;
		}
		
		public function get imageWidth():Number {
			return _imageWidth;
		}
		
		public function get imageHeight():Number {
			return _imageHeight;
		}

		public function getTierWidth(tier:uint):Number {
			var tierWidth:Number = imageWidth;
			for(var i:uint = numTiers; i > tier+1; i--) {
				tierWidth /= 2;
			}
			return tierWidth;
		}

		public function getTierHeight(tier:uint):Number {
			var tierHeight:Number = imageHeight;
			for(var i:uint = numTiers; i > tier+1; i--) {
				tierHeight /=2;
			}
			return tierHeight;
		}
				
		public function get imageTileSize():Number {
			return _imageTileSize;
		}
		
		public function get scaleUpThreshold():Number {
			return _tierScaleUpThreshold; 
		}
		
		public function set scaleUpThreshold(value:Number):void {
			_tierScaleUpThreshold = value;
		}
		
		public function get scaleDownThreshold():Number {
			return _tierScaleDownThreshold;
		}
		
		public function set scaleDownThreshold(value:Number):void {
			_tierScaleDownThreshold = value;
		}
				
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::: CORE METHODS :::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		/**
		 * @private (protected)
		 */
		protected function enterFrameHandler(event:Event):void {				
			if((toolbarZoomFlag != 0 || targetZoomDecimal != 0 || targetPanX != 0 || targetPanY != 0 || toolbarHorizontalFlag != 0 || toolbarVerticalFlag != 0) && zoomToViewTimer.running) { zoomToViewStop(); }
			if(!grid || zoomToViewTimer.running) { return; }
			if(toolbarZoomFlag == -1) {
				dispatchEvent(new Event("viewZoomingOutInternal"));
				if(_eventsEnabled) {
					viewZooming = true;
					dispatchEvent(new Event("viewZoomingOut"));
				}
				setZoomDecimal(Math.max(minZoomDecimal, getZoomDecimal() * (1 - zoomFactor)), true);
				targetZoomDecimal = 0;
			} else if(toolbarZoomFlag == 1) {
				dispatchEvent(new Event("viewZoomingInInternal"));
				if(_eventsEnabled) {
					viewZooming = true;
					dispatchEvent(new Event("viewZoomingIn"));
				}
				setZoomDecimal(Math.min(maxZoomDecimal, getZoomDecimal() * (1 + zoomFactor)), true);
				targetZoomDecimal = 0;
			} else if(targetZoomDecimal != 0) {
				if(_eventsEnabled) { viewZooming = true; }
				if(targetZoomDecimal < currentTierScale) {
					dispatchEvent(new Event("viewZoomingOutInternal"));
					if(_eventsEnabled) { dispatchEvent(new Event("viewZoomingOut")); }
				} else if(targetZoomDecimal > currentTierScale) {
					dispatchEvent(new Event("viewZoomingInInternal"));
					if(_eventsEnabled) { dispatchEvent(new Event("viewZoomingIn")); }
				}
				if(Math.abs(targetZoomDecimal - currentTierScale) < 0.001) {
					modifyCurrentTierScaleRelatively(targetZoomDecimal - currentTierScale, zoomPoint);
					targetZoomDecimal = 0;
					invalidate(InvalidationType.STATE);
				} else {
					modifyCurrentTierScaleRelatively((targetZoomDecimal - currentTierScale) / 2, zoomPoint);
				}
				if(getZoomDecimal() < minZoomDecimal) {
					setZoomDecimal(minZoomDecimal, false);
					targetZoomDecimal = 0;
					invalidate(InvalidationType.STATE);
				} else if(getZoomDecimal() > maxZoomDecimal) {
					setZoomDecimal(maxZoomDecimal, false);
					targetZoomDecimal = 0;
					invalidate(InvalidationType.STATE);
				}
				dispatchEvent(new Event("gridChanged"));
				dispatchEvent(new Event("areaChanged"));
			}
			if(targetPanX != 0 || targetPanY != 0) {
				targetPanX /= 2;
				targetPanY /= 2;
				var r:int = moveCanvas(targetPanX, targetPanY);
				if((r & 1) || Math.abs(targetPanX) < 1.0) { targetPanX = 0; }
				if((r & 2) || Math.abs(targetPanY) < 1.0) { targetPanY = 0; }
				if(targetPanX == 0 && targetPanY == 0) {
					invalidate(InvalidationType.STATE);
				}
			} else if(toolbarHorizontalFlag != 0 || toolbarVerticalFlag != 0) {
				moveCanvas(toolbarHorizontalFlag * 6, toolbarVerticalFlag * 6);
			} else if((viewPanning || viewZooming) && (!mouseIsDown && !externalPanning && !externalZooming)) {
				if(viewPanning) { 
					viewPanning = false;
					if(_eventsEnabled) { dispatchEvent(new Event("viewPanComplete")); }
				}
				if(viewZooming && toolbarZoomFlag == 0 && targetZoomDecimal == 0) { 
					viewZooming = false;
					if(_eventsEnabled) { dispatchEvent(new Event("viewZoomComplete")); }
					if(getZoomDecimal() == maxZoomDecimal) { dispatchEvent(new Event("zoomConstrainedToMax")); }
					if(getZoomDecimal() == minZoomDecimal) { dispatchEvent(new Event("zoomConstrainedToMin")); }
				}
			}
		}

		/**
		 * @private (protected)
		 */
		protected function updateTierTimerHandler(event:TimerEvent):void {
			invalidate(InvalidationType.STATE);
		}
		
		/**
		 * @private (protected)
		 */
		override public function setSize(width:Number, height:Number):void {
			this.enabled = false;
			if(grid) {
				var priorWidth:Number = this.width;
				var priorHeight:Number = this.height;
			}
			super.setSize(width, height);
			if(grid) {			
				var zoom:Number = getZoomDecimal();
				var widthDelta:Number = priorWidth - width;
				var heightDelta:Number = priorHeight - height;
				var priorOffset:Point = getImageOffset();
				var newOffsetX:Number = priorOffset.x - (widthDelta / 2);
				var newOffsetY:Number = priorOffset.y - (heightDelta / 2);
				var newOffset:Point = new Point(newOffsetX, newOffsetY);
				cacheView();
				grid.configureCanvas(imageTileSize, width, height, imageWidth, imageHeight, currentTier, _tierScaleDownThreshold, tierWidthsInTilesArray, tierHeightsInTilesArray);
				setZoomDecimal(zoom);
				setImageOffset(newOffset);
				currentTierScale = grid.getCurrentTierScale();
				invalidate(InvalidationType.SIZE);
				invalidate(InvalidationType.STATE);
				drawNow();
				dispatchEvent(new Event("gridChanged"));
				dispatchEvent(new Event("areaChanged"));
			}
			this.enabled = true;
		}
		
		/**
		 * @private (protected)
		 */
		public function updateTier():void {
			var newTier:int = currentTier;
			if((currentTierScale > _tierScaleUpThreshold && currentTier + 1 < numTiers) || (currentTierScale <= _tierScaleDownThreshold && currentTier - 1 >= 0) ){
				var bmp:BitmapData;
				var offset:Point;
				bmp = swapBuffer();
				bmp.lock();
				bmp.fillRect(new Rectangle(0, 0, bmp.width, bmp.height), 0x00FFFFFF);
				bmp.draw(this, null, null, null, null, true);
				bmp.unlock();	
				newTier = selectTier();
				grid.active(false);
				offset = grid.getOffset();				
				grid.updateCanvas(imageTileSize, imageWidth, imageHeight, newTier, tierWidthsInTilesArray, tierHeightsInTilesArray);
				grid.setPriorBitmap(bmp);
				grid.active(true);
				grid.resetScale(currentTierScale);
				grid.setOffset(offset, tierWidthsArray[newTier]);
			}
			grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), newTier, tierWidthsArray[newTier], tierHeightsArray[newTier], tierWidthsInTilesArray[newTier], tierHeightsInTilesArray[newTier], true);
			currentTier = newTier;
		}
		
		/**
		 * @private (protected)
		 */
		 // Begin at full image and loop and decrement to find best new tier.
		 // Add threshold to zoomTest to bias powers of 2 tier calculations and permit limited scale-up
		 // of tiers other than full resolution tier. Converting to global zoom to select new tier and 
		 // then converting back to scale new tier rather than counting and scaling up or down from current 
		 // tier avoids different code for zooming in and out and associated risk of inconsistent tier 
		 // selection at any specific zoom level depending on whether arrived at from below or above.
		protected function selectTier():int {
			var newTier:int = numTiers;  
			var zoomTest:Number = 1.0 * _tierScaleUpThreshold; 
			var currentZoom:Number = convertCurrentTierScaleToZoom(currentTierScale, grid.getCurrentTier());
			while(zoomTest/2 >= currentZoom)
			{
				newTier--;
				zoomTest/=2;
			}
			if(newTier > 0) { newTier--; } // Convert from tier count to tier base 0 name.
			if(newTier < 0) { newTier = 0; }
			currentTierScale = convertZoomToCurrentTierScale(currentZoom, newTier);
			scaleCalc = currentTierScale;
			return newTier;
		}

		/**
		 * @private (protected)
		 */
		protected function moveCanvas(x:Number, y:Number):int {
			if(x == 0 && y == 0) { return 0; }
			var p:int = grid.offsetCanvas(x, y);
			grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), currentTier, tierWidthsArray[currentTier], tierHeightsArray[currentTier], tierWidthsInTilesArray[currentTier], tierHeightsInTilesArray[currentTier], false);
			if(_eventsEnabled) { 
				viewPanning = true;
				dispatchEvent(new Event("viewPanning")); 
			}
			dispatchEvent(new Event("areaChanged"));
			return p;
		}
		
		/**
		 * @private (protected)
		 */
		protected function modifyCurrentTierScale(n:Number, zp:Point, dispatchScaleEvent:Boolean = true):void {
			currentTierScale += n;
			var g:Point = new Point(zp.x, zp.y);
			g = localToGlobal(g);
			grid.scaleCurrentTier(currentTierScale, g.x, g.y);
			if(_eventsEnabled) { viewZooming = true; }
			if(n > 0) { 
				dispatchEvent(new Event("viewZoomingInInternal"));
				if(_eventsEnabled) { dispatchEvent(new Event("viewZoomingIn")); }
			}else if(n < 0) {
				dispatchEvent(new Event("viewZoomingOutInternal"));			
				if(_eventsEnabled) { dispatchEvent(new Event("viewZoomingOut")); }
			}		
			// Event dispatch used to update external elements such as toolbar slider.
			// Not necessary if this rescaling caused by user interaction with toolbar slider.
			if(dispatchScaleEvent) {
				dispatchEvent(new Event("gridChanged"));
			} else {  
				// Next line useful if tracking all zooming in non events-disableable manner.
				dispatchEvent(new Event("gridChangedBySlider")); 
			}
			dispatchEvent(new Event("areaChanged"));
		}

		/**
		 * @private (protected)
		 */
		protected function modifyCurrentTierScaleRelatively(n:Number, zp:Point):void {
			currentTierScale += n;
			var center:Point = new Point(width / 2, height / 2);
			center = localToGlobal(center);
			grid.scaleCurrentTierRelatively(currentTierScale, zp.x, zp.y, center);
		}
		
		/**
		 * @private (protected)
		 */
		protected function swapBuffer():BitmapData {
			currentCacheView = (currentCacheView == cachedView1) ? cachedView2 : cachedView1;
			return currentCacheView;
		}
		
		/**
		 * @private (protected)
		 */
		protected function cacheView():void {
			var bmp:BitmapData = swapBuffer();
			bmp.lock();
			bmp.fillRect(new Rectangle(0, 0, bmp.width, bmp.height), 0x00FFFFFF);
			bmp.draw(this, null, null, null, null, true);
			bmp.unlock();
			grid.setPriorBitmap(bmp);
			var offset:Point = grid.getOffset();
			grid.setOffset(offset, tierWidthsArray[currentTier]);
			grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), currentTier, tierWidthsArray[currentTier], tierHeightsArray[currentTier], tierWidthsInTilesArray[currentTier], tierHeightsInTilesArray[currentTier], false);
		}
		
		public function getImageOffset():Point {
			return grid.getImageOffset();
		}
		
		public function setImageOffset(pt:Point):void {
			if(_eventsEnabled) {
				viewPanning = true;
				dispatchEvent(new Event("viewPanning"));
			}
			grid.setImageOffset(pt);
		}
		
		/**
		 * @private (protected)
		 */
		override protected function draw():void {
			if(isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}
			if(isInvalid(InvalidationType.STATE) && grid != null) {
				updateTier();
				dispatchEvent(new Event("gridChanged"));
				dispatchEvent(new Event("areaChanged"));
			}
			super.draw();
		}
		
		/**
		 * @private (protected)
		 */
		protected function drawLayout():void {
			drawScrollRect();
			positionSplashScreen();
			positionMessageScreen();
		}		
		
		/**
		 * @private (protected)
		 */
		protected function drawScrollRect():void {
			contentScrollRect = content.scrollRect;
			contentScrollRect.width = width;
			contentScrollRect.height = height;
			content.scrollRect = contentScrollRect;
		}
		
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::: INTERACTION METHODS ::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public function zoomIn():void {
			toolbarZoomFlag = 1;
		}

		public function zoomOut():void {
			toolbarZoomFlag = -1;
		}

		public function zoomStop():void {
			toolbarZoomFlag = 0;
		}

		public function panUp():void {
			toolbarVerticalFlag = 1;
		}

		public function panDown():void {
			toolbarVerticalFlag = -1;
		}

		public function panLeft():void {
			toolbarHorizontalFlag = 1;
		}

		public function panRight():void {
			toolbarHorizontalFlag = -1;
		}

		public function panStop():void {
			toolbarVerticalFlag = 0;
			toolbarHorizontalFlag = 0;
		}
				
		public function setView(x:Number, y:Number, zoom:Number):void {
			viewX = x;
			viewY = y;
			viewZoom = zoom;
		}

		public function setInitialView():void {
			setView(_initialX, _initialY, initialZoom);
		}

		public function zoomToInitialView():void {
			zoomToView(_initialX, _initialY, initialZoom, 250, 10);
		}				

		// Duration and stepDuration in milliseconds (recommend: 100 < duration < 2000 & 10 < stepDuration < 100).
		// To test completion, listen for event zoomToViewTimer.timerComplete.
		// To test for zoomToView in progress test zoomToViewTimer.running.
		public function zoomToView(x:Number, y:Number, zoom:Number, duration:Number, stepDuration:Number) : void {
			if(grid) {			
				zoomToViewStop();	

				if(x < 0) { x = 0; }
				if(x > imageWidth) { x = imageWidth; }		
				changeXStart = grid.x;
				changeXSpan = x - grid.x

				if(y < 0) { y = 0; }
				if(y > imageHeight) { y = imageHeight; }
				changeYStart = grid.y;
				changeYSpan = y - grid.y;

				if(zoom == -1) { zoom = calcZoomDecimalToFitDisplay() * 100; } 
				if(zoom / 100 < minZoomDecimal) { zoom = minZoomDecimal * 100; }
				if(zoom / 100 > maxZoomDecimal) { zoom = maxZoomDecimal * 100; }
				changeCurrentTierScaleStart = currentTierScale;
				changeCurrentTierScaleSpan = ((convertZoomToCurrentTierScale(zoom, grid.getCurrentTier()) / 100) - currentTierScale);

				zoomToViewTimer = new Timer(stepDuration, duration / stepDuration);
				zoomToViewTimer.addEventListener("timer", zoomToViewTimerHandler, false, 0, true);
				zoomToViewTimer.start();
			}
		}

		private function zoomToViewTimerHandler(event:TimerEvent):void {
			var currentTime:Number = event.target.currentCount * event.target.delay;
			var duration:Number = event.target.repeatCount * event.target.delay; 

			if(changeCurrentTierScaleSpan != 0 ) {
				if(_eventsEnabled){	viewZooming = true; }
				if(changeCurrentTierScaleSpan > 0) { 
					dispatchEvent(new Event("viewZoomingInInternal")); 
					if(_eventsEnabled){	dispatchEvent(new Event("viewZoomingIn")); }
				}else if(changeCurrentTierScaleSpan < 0) {
					dispatchEvent(new Event("viewZoomingOutInternal")); 	
					if(_eventsEnabled){	dispatchEvent(new Event("viewZoomingOut")); }			
				}	
				currentTierScale = grid.scaleX = grid.scaleY = changeEaseInOut(currentTime, changeCurrentTierScaleStart, changeCurrentTierScaleSpan, duration);
				dispatchEvent(new Event("gridChanged"));
			}			
			grid.x = changeEaseInOut(currentTime, changeXStart, changeXSpan, duration);
			grid.y = changeEaseInOut(currentTime, changeYStart, changeYSpan, duration);
			grid.constrainPan();
			dispatchEvent(new Event("areaChanged"));

			if(event.target.currentCount == event.target.repeatCount){
				event.target.stop();
				event.target.reset();
				event.target.removeEventListener("timer", zoomToViewTimerHandler);
				targetPanX = 0;
				targetPanY = 0;
				targetZoomDecimal = 0;
				invalidate(InvalidationType.STATE);				
				if(_eventsEnabled) { dispatchEvent(new Event("viewPanComplete")); }
				if(_eventsEnabled) { dispatchEvent(new Event("viewZoomComplete")); }
			}
		}

		public function zoomToViewStop():void {
			if(zoomToViewTimer.running) {
				zoomToViewTimer.repeatCount = zoomToViewTimer.currentCount;
			}
		}
		
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: EVENT HANDLERS :::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		/**
		 * @private (protected)
		 */
		protected function mouseDownHandler(event:MouseEvent):void  {
			if(_eventsEnabled) { dispatchEvent(new Event("viewerMouseDown")); }
			dragged = false;
			if(!grid) { return; }
			if(content.contains(DisplayObject(event.target))) {
				ignoreMouseUp = false;
				dispatchEvent(new Event("prepareForUserInteraction"));
			}
			if(mouseY < height) { 
				mouseIsDown = true;
			}
			lastMouse = new Point(mouseX, mouseY);
			hit = new Point(mouseX, mouseY);
			zoomPoint = grid.getMousePosition();
			scaleCalc = grid.getCurrentTierScale();
			currentTierScale = scaleCalc;
		}
		
		/**
		 * @private (protected)
		 */
		protected function mouseUpHandler(event:MouseEvent):void {
			if(_eventsEnabled) { dispatchEvent(new Event("viewerMouseUp")); }
			if(!dragged && !ignoreMouseUp) {
				if(!_clickZoom || ((event.altKey && getZoomDecimal() == minZoomDecimal) || (!event.altKey && getZoomDecimal() == maxZoomDecimal))){
					targetPanX = width / 2 - mouseX;
					targetPanY = height / 2 - mouseY;
					dispatchEvent(new Event("viewPanning"));
					if(_eventsEnabled) { dispatchEvent(new Event("viewPanning")); }
					return;
				}else{
					var sc:Number = (event.altKey) ? (1 << grid.getCurrentTier() - 1) : (1 << Math.min(grid.getCurrentTier() + 1, numTiers - 1));
					zoomPoint = grid.getMousePosition();
					targetZoomDecimal = (sc / (1 << grid.getCurrentTier()));
				}
			}
			ignoreMouseUp = true;
		}
		
		protected function stageMouseWheelHandler(event:MouseEvent):void {
			if(_eventsEnabled) { dispatchEvent(new Event("stageMouseWheel")); }
			var zoomSpeedAdj:Number = event.delta * 3.5;
			var zoomFactor:Number = 1 / (1000 / (zoomSpeedAdj * zoomSpeedAdj));
			var zoomMultiplier:Number = (event.delta > 1) ? 1 + zoomFactor : 1 - zoomFactor;
			var sc:Number = getZoomDecimal() * zoomMultiplier;
			if(sc < minZoomDecimal) { sc = minZoomDecimal; }
			if(sc > maxZoomDecimal) { sc = maxZoomDecimal; }
			setZoomDecimal(sc, true);
			if(updateTierTimer.running) {
				updateTierTimer.reset();
			} else {
				dispatchEvent(new Event("prepareForUserInteraction"));
			}
			updateTierTimer.start();
		}

		/**
		 * @private (protected)
		 */
		protected function stageMouseUpHandler(event:MouseEvent):void {
			if(!grid) { return; }
			if(spaceZooming) {
				invalidate(InvalidationType.STATE);
			} else if(mouseIsDown) {
				grid.updateTiles(width, height, getViewXImageSpan(), getViewYImageSpan(), currentTier, tierWidthsArray[currentTier], tierHeightsArray[currentTier], tierWidthsInTilesArray[currentTier], tierHeightsInTilesArray[currentTier], true);
			}
			spaceZooming = false;
			mouseIsDown = false;
		}
		
		/**
		 * @private (protected)
		 */
		protected function stageMouseMoveHandler(event:MouseEvent):void {
			if(_eventsEnabled) { dispatchEvent(new Event("stageMouseMove")); }
			if(!grid) { return; }
			if(mouseIsDown) {
				if(spaceZooming) {	
					var priorCurrentTierScale:Number = currentTierScale;
					modifyCurrentTierScaleRelatively((lastMouse.y - mouseY) / 100.0, zoomPoint);
					var zoom:Number = currentTierScale / priorCurrentTierScale;
					hit.x /= zoom;
					hit.y *= zoom;
				} else {
					grid.offsetCanvas(mouseX - hit.x, mouseY - hit.y);
					hit = new Point(mouseX, mouseY);
				}
				viewPanning = true;
				dispatchEvent(new Event("viewPanning"));
				dispatchEvent(new Event("areaChanged"));
				dragged = true;
			}
			lastMouse.x = mouseX;
			lastMouse.y = mouseY;
		}
		
		/**
		 * @private (protected)
		 */
		protected function stageKeyDownHandler(event:KeyboardEvent):void {
			switch (event.charCode) {
				case 97: // The 'a' key.
					toolbarZoomFlag = 1;
					targetZoomDecimal = 0;
					break;
				case 122: // The 'z' key.
					toolbarZoomFlag = -1;
					targetZoomDecimal = 0;
					break;
			}
			switch(event.keyCode) {
				case Keyboard.SPACE:
					spaceZooming = true;
					break;
				case Keyboard.SHIFT:
					toolbarZoomFlag = 1;
					targetZoomDecimal = 0;
					break;
				case Keyboard.CONTROL:
					toolbarZoomFlag = -1;
					targetZoomDecimal = 0;
					break;
				case Keyboard.LEFT:
					toolbarHorizontalFlag = 1;
					break;
				case Keyboard.RIGHT:
					toolbarHorizontalFlag = -1;
					break;
				case Keyboard.UP:
					toolbarVerticalFlag = 1;
					break;
				case Keyboard.DOWN:
					toolbarVerticalFlag = -1;
					break;
			}
			if(toolbarZoomFlag != 0 || toolbarHorizontalFlag != 0 || toolbarVerticalFlag != 0) {
				if(_eventsEnabled) { dispatchEvent(new Event("viewerKeyDown")); }
				dispatchEvent(new Event("prepareForUserInteraction"));
			}
		}

		/**
		 * @private (protected)
		 */
		protected function stageKeyUpHandler(event:KeyboardEvent):void {
			switch (event.charCode) {
				case 97: // The 'a' key.
					if(toolbarZoomFlag == 1) {
						toolbarZoomFlag = 0;
						invalidate(InvalidationType.STATE);
					}
					break;
				case 122: // The 'z' key.
					if(toolbarZoomFlag == -1) {
						toolbarZoomFlag = 0;
						invalidate(InvalidationType.STATE);
					}
					break;
			}
			switch(event.keyCode) {
				case Keyboard.SHIFT:
					if(toolbarZoomFlag == 1) {
						toolbarZoomFlag = 0;
						invalidate(InvalidationType.STATE);
					}
				case Keyboard.CONTROL:
					if(toolbarZoomFlag == -1) {
						toolbarZoomFlag = 0;
						invalidate(InvalidationType.STATE);
					}
					break;
					// Fall through.
				case Keyboard.SPACE:
					spaceZooming = false;
					break;
				case Keyboard.LEFT:
					toolbarHorizontalFlag = 0;
					break;
				case Keyboard.RIGHT:
					toolbarHorizontalFlag = 0;
					break;
				case Keyboard.UP:
					toolbarVerticalFlag = 0;
					break;
				case Keyboard.DOWN:
					toolbarVerticalFlag = 0;
					break;
				case Keyboard.ESCAPE:			
					dispatchEvent(new Event("prepareForUserInteraction"));
					setInitialView();	
					break;
			}
			if((toolbarZoomFlag == 0 && toolbarHorizontalFlag == 0 && toolbarVerticalFlag == 0) || event.keyCode == Keyboard.ESCAPE) {
				if(_eventsEnabled) { dispatchEvent(new Event("viewerKeyUp")); }
			}
		}
		
		/**
		 * @private (protected)
		 */
		protected function splashScreenClickHandler(event:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.zoomify.com"), "_blank");
		}
		
		/**
		 * @private (protected)
		 */
		protected function messageScreenClickHandler(event:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.zoomify.com"), "_blank");
		}
		
		/**
		 * @private (protected)
		 */
		protected function tileProgressHandler(event:TileProgressEvent):void {
			dispatchEvent(event.clone());
		}
		
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::: SUPPORT METHODS ::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		protected function clearAll() { 
			clearCachedViews(); 
			clearImage();
		}

		public function clearCachedViews():void {
			tileCache.purge(0);
			if(cachedView1) { cachedView1.dispose(); }
			if(cachedView1) { cachedView2.dispose(); }
			if(currentCacheView) { currentCacheView.dispose(); }
		}
		
		protected function clearImage() { 
			grid.clearTiles();
			grid = null;
			content.removeChildAt(0);
			currentTier = 0;
		}
		
		protected function convertCurrentTierScaleToZoom(scale:Number, tier:int):Number {
			var zoom:Number = scale * (getTierWidth(tier) / imageWidth);
			return zoom; 
		}
		
		protected function convertZoomToCurrentTierScale(zoom:Number, tier:int):Number {
			var scale:Number = zoom / (getTierWidth(tier) / imageWidth);
			return scale; 
		}
		
		/**
		 * @private (protected)
		 */
		public function zoomToFitDisplay():void {
			setZoomDecimal(calcZoomDecimalToFitDisplay(), false);
			invalidate(InvalidationType.STATE);
		}
		
		public function calcZoomDecimalToFitDisplay():Number {
			return (imageWidth / imageHeight > width / height) ? width / imageWidth : height / imageHeight;
		}
		
		protected function convertZoomPercentToDecimal(zoomValue:Number):Number {
			if(zoomValue == -1) {
				return calcZoomDecimalToFitDisplay();
			} else {
				return zoomValue / 100;
			}
		}		
		
		protected function calcZoomConstraints(): void {
			minZoomDecimal = getMinimumZoomDecimal();
			maxZoomDecimal = getMaximumZoomDecimal();	
		}
		
		// Key: t=current time, b=start value, c=total span, d=duration (Quintic transition easeInOut)
		public function changeEaseInOut(t:Number, b:Number, c:Number, d:Number):Number	{
			if ((t /= d / 2) < 1){
				return c / 2 * t * t * t * t * t + b;
			}else{
				return c / 2 * ((t -= 2) * t * t * t * t + 2) + b;
			}
		}

		/**
		 * @private (protected)
		 */
		protected function positionSplashScreen():void {
			logoSplashScreen.x = (width - logoSplashScreen.width) / 2; 
			logoSplashScreen.y = (height - logoSplashScreen.height) / 2;
		}

		/**
		 * @private (protected)
		 */
		protected function positionMessageScreen():void {
			textMessageScreen.x = (width - textMessageScreen.width) / 2;
			textMessageScreen.y = (height - textMessageScreen.height) / 2;
		}
		
		public function showMessage(msg:String = null):void {
			textMessageScreen.visible = true;
			for(var i:uint = 0; i < textMessageScreen.numChildren; i++) {
				var s:MessageScreen = textMessageScreen.getChildAt(i) as MessageScreen;
				if(s != null) {
					s.setMessage((msg == null) ? "" : msg);
					break;
				}
			}
		}
		
		public function hideMessage():void {
			textMessageScreen.visible = false;
		}
		
		// Not currently used.  Debugging tool.
		public function getTierPowerOf2():Number {
			return (1 << grid.getCurrentTier()) * currentTierScale;
		}

		// Not currently used.  
		public function convertPixelCoordToImageSpan(pixelPosition:Number, targetViewer:ZoomifyViewer, dimension:String):Number {	
			if(dimension == "width"){		
				return pixelPosition * ((((targetViewer.imageWidth/2)+1) / targetViewer.imageWidth)-0.5);
			}else{
				return pixelPosition * ((((targetViewer.imageHeight/2)+1) / targetViewer.imageHeight)-0.5);
			}
		}

		// Not currently used.  
		public function convertImageSpanToPixelCoord(imageSpanCoord:Number, targetViewer:ZoomifyViewer, dimension:String):Number {
			if(dimension == "width"){
				return (imageSpanCoord + 0.5) * targetViewer.imageWidth;
			}else{
				return (imageSpanCoord + 0.5) * targetViewer.imageHeight;
			}
		}
	}
}

