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
	import flash.utils.*;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.events.Event;    
	import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.EventDispatcher;
	import flash.net.*;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	import fl.core.UIComponent;
	import fl.core.InvalidationType;
	import fl.controls.Button;
	import fl.controls.Slider;
	import fl.managers.IFocusManagerComponent;
	import zoomify.IZoomifyViewer;
	import zoomify.viewer.TileCache;
	import zoomify.viewer.TileDataLoader;
	import zoomify.toolbar.HighSlider;
	import zoomify.utils.Tooltip;
	import zoomify.utils.Resources;
    

	//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	//:::::::::::::::::::::::::::::::::::::::: STYLES ::::::::::::::::::::::::::::::::::::::::
	//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

	/**
	 *  Style description background
	 *
	 *  @default ZoomifyToolbar_background
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.28.0
	 */
    	[Style(name="background", type="Class")]

	/**
	 *  Style description divider
	 *
	 *  @default ZoomifyToolbar_divider
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.28.0
	 */
    	[Style(name="divider", type="Class")]

	/**
	 *  Style description logo
	 *
	 *  @default ZoomifyToolbar_logo
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.28.0
	 */
	[Style(name="logo", type="Class")]

	/**
	 *  Style description toolbarAlert
	 *
	 *  @default ZoomifyToolbar_alert
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.28.0
	 */
	[Style(name="toolbarAlert", type="Class")]
	
	
	public class ZoomifyToolbar extends UIComponent implements IFocusManagerComponent
	{
			
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: INIT METHODS :::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		protected var content:Sprite;
		protected var logo:Sprite;
		
		protected var alertOverlay:Sprite;
		protected var skinError:String = "";

		protected var background:DisplayObject;
		protected var toolbarLogo:DisplayObject;
		protected var logoDivider:DisplayObject;
		protected var zoomOut:Button;
		protected var slider:HighSlider;
		protected var zoomIn:Button;
		protected var zoomPanDivider:DisplayObject;
		protected var panLeft:Button;
		protected var panUp:Button;
		protected var panDown:Button;
		protected var panRight:Button;
		protected var reset:Button;

		protected var moving:Boolean = false;
		protected var contentWidth:Number = 0;

		protected var _viewer:IZoomifyViewer;
		protected var _showSlider:Boolean = true;
		protected var _showZoomifyButton:Boolean = true;
		protected	var _showToolbarTooltips:Boolean = true;
	
		protected	var _toolbarSpacing:Number = 7;
		protected	var _toolbarSkinXMLPath:String = "unset";
		protected var toolbarSkinFolderPath:String = "";
		protected var toolbarSkinArray:Array =  [];
		protected var toolbarSkinLoadedArray:Array =  [];
		protected var toolbarSkinCounter:uint = 0;
		protected var toolbarSkinCounterMax:uint = 30-1; // 30 skin files, numbered 0 to 29.
		protected var toolbarSkinLoader:Loader = new Loader();
		
		protected	var minZoomDecimal:Number;
		protected var maxZoomDecimal:Number;	
		
		/**
		 * @private
		 */
		private static var defaultStyles:Object = {
			background: "ZoomifyToolbar_background",
			divider: "ZoomifyToolbar_divider",
			logo: "ZoomifyToolbar_logo",
			toolbarAlert: "ZoomifyToolbar_alert"
		}

		public static function getStyleDefinition():Object { return defaultStyles; }
		
		/**
		 * Creates a new ZoomifyToolbar component instance.
		 */
		public function ZoomifyToolbar():void
		{
			super();
		}
		
		/**
		 * @private (protected)
		 */
		override protected function configUI():void {
			super.configUI();
			configBegin();
		}

		protected function configBegin(event:Event = null):void {
			if(_toolbarSkinXMLPath != "unset") { 
				var isLivePreview:Boolean = (parent != null && getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent");
				if(isLivePreview || _toolbarSkinXMLPath == null || _toolbarSkinXMLPath == "" || _toolbarSkinXMLPath == "/") { 
					configSkin();
				} else {
					loadToolbarSkinXML(); 
				}
			}
		}
		
		protected function configSkin():void {
			if(toolbarSkinArray.length == 0) {
				background = getDisplayObjectInstance(getStyleValue("background"));
				toolbarLogo = getDisplayObjectInstance(getStyleValue("logo"));
				logoDivider = getDisplayObjectInstance(getStyleValue("divider"));
			} else {
				background = toolbarSkinLoadedArray[0]; 
				toolbarLogo = toolbarSkinLoadedArray[1]; 
				logoDivider = toolbarSkinLoadedArray[2]; 
			}
			
			logo = new Sprite();
			logo.buttonMode = true;
			logo.addEventListener(MouseEvent.MOUSE_OVER, logoRolloverHandler, false, 0, true); 
			logo.addEventListener(MouseEvent.MOUSE_DOWN, logoMouseDownHandler, false, 0, true);
			logo.addChild(toolbarLogo);
			logo.visible = showZoomifyButton;

			logoDivider.visible = showZoomifyButton;
			
			addChild(background);
			addChild(logo);
			addChild(logoDivider);
			
			content = new Sprite();
			addChild(content);
			
			configSkinContent();
			configComplete();
		}
		
		/**
		 * @private (protected)
		 */
		protected function configSkinContent():void {
			zoomOut = new Button();
			configButton(zoomOut, zoomOutMouseDownHandler, zoomOutRolloverHandler, 3, "iconMinus");
			content.addChild(zoomOut);
			
			slider = new HighSlider();
			slider.minimum = 0;
			slider.maximum = 20000;
			slider.snapInterval = 10;
			slider.tickInterval = 1000;
			slider.value = 0;
			if(toolbarSkinLoadedArray[6] != null) {
				slider.setStyle("sliderTrackSkin", toolbarSkinLoadedArray[6]);
				// DEV NOTE: Potential Flash issue: following line ineffective.  Placeholder
				// graphic mitigates (matches background).  Default available: "SliderTick_skin".
				slider.setStyle("tickSkin", toolbarSkinLoadedArray[6 + 1]); 
				var thumbUpContainer:Sprite = new Sprite();
				thumbUpContainer.addChild(toolbarSkinLoadedArray[6 + 2]);
				thumbUpContainer.getChildAt(0).x -= thumbUpContainer.getChildAt(0).width / 2;
				slider.setStyle("thumbUpSkin", thumbUpContainer);
				var thumbOverContainer:Sprite = new Sprite();
				thumbOverContainer.addChild(toolbarSkinLoadedArray[6 + 3]);
				thumbOverContainer.getChildAt(0).x -= thumbOverContainer.getChildAt(0).width / 2;
				slider.setStyle("thumbOverSkin", thumbOverContainer);
				var thumbDownContainer:Sprite = new Sprite();
				thumbDownContainer.addChild(toolbarSkinLoadedArray[6 + 4]);
				thumbDownContainer.getChildAt(0).x -= thumbDownContainer.getChildAt(0).width / 2;
				slider.setStyle("thumbDownSkin", thumbDownContainer);	
			}
			slider.addEventListener("change", sliderChangeHandler);
			slider.addEventListener("thumbDrag", sliderDragHandler);
			slider.addEventListener(MouseEvent.MOUSE_OVER, sliderRolloverHandler, false, 0, true); 
			slider.addEventListener(MouseEvent.MOUSE_DOWN, sliderMouseDownHandler, false, 0, true);
			slider.visible = showSlider;
			content.addChild(slider);
			
			zoomIn = new Button();
			configButton(zoomIn, zoomInMouseDownHandler, zoomInRolloverHandler, 11, "iconPlus");
			content.addChild(zoomIn);
	
			if(toolbarSkinLoadedArray[14] == null) {
				zoomPanDivider = getDisplayObjectInstance(getStyleValue("divider"));
			} else {
				zoomPanDivider = toolbarSkinLoadedArray[14]; 
			}
			content.addChild(zoomPanDivider);
			
			panLeft = new Button();
			configButton(panLeft, panLeftMouseDownHandler, panLeftRolloverHandler, 15, "iconArrowLeft");
			content.addChild(panLeft);

			panUp = new Button();
			configButton(panUp, panUpMouseDownHandler, panUpRolloverHandler, 18, "iconArrowUp");
			content.addChild(panUp);

			panDown = new Button();
			configButton(panDown, panDownMouseDownHandler, panDownRolloverHandler, 21, "iconArrowDown");
			content.addChild(panDown);

			panRight = new Button();
			configButton(panRight, panRightMouseDownHandler, panRightRolloverHandler, 24, "iconArrowRight");
			content.addChild(panRight);

			reset = new Button();
			configButton(reset, resetMouseDownHandler, resetRolloverHandler, 27, "iconReset");
			content.addChild(reset);
		}

		/**
		 * @private (protected)
		 */ 
		protected function configButton(btn:Button, mouseDownHandler:Function, mouseRolloverHandler:Function, iconSkinIndex:Number, iconClassName:String):void {
			var iconClass:Class = ApplicationDomain.currentDomain.getDefinition(iconClassName) as Class;
			btn.setStyle("disabledIcon", iconClass); // Skinning disabled skin not supported currently.
			if(toolbarSkinLoadedArray[iconSkinIndex] == null) {
				btn.setStyle("icon", iconClass);
				btn.setStyle("overIcon", iconClass);
				btn.setStyle("downIcon", iconClass);
			} else {
				toolbarSkinLoadedArray[iconSkinIndex].scaleX = toolbarSkinLoadedArray[iconSkinIndex].scaleY = 1;
				toolbarSkinLoadedArray[iconSkinIndex + 1].scaleX = toolbarSkinLoadedArray[iconSkinIndex + 1].scaleY = 1;
				toolbarSkinLoadedArray[iconSkinIndex + 2].scaleX = toolbarSkinLoadedArray[iconSkinIndex + 2].scaleY = 1;
				btn.setStyle("icon", toolbarSkinLoadedArray[iconSkinIndex]);
				btn.setStyle("overIcon", toolbarSkinLoadedArray[iconSkinIndex + 1]);
				btn.setStyle("downIcon", toolbarSkinLoadedArray[iconSkinIndex + 2]);
			}
			btn.label = "";
			btn.addEventListener(MouseEvent.MOUSE_OVER, mouseRolloverHandler, false, 0, true); 
			btn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
		}
		
		protected function configComplete(event:Event = null):void {
			drawLayout();
			initializeStageMouseListeners();
			setToolbarSliderZoomDecimal();
			validateShowToolbarTooltips(); 
			validateSkins();
			if(_viewer) {
				if(!_viewer.initialized) {
					_viewer.addEventListener("viewerInitializationCompleteInternal", configComplete, false, 0, true);
				}else {
					_viewer.removeEventListener("viewerInitializationCompleteInternal", configComplete);
				}
			}	
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
			if (isInvalid(InvalidationType.SIZE)) { drawLayout(); }
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
			} catch(e:Error) {
			}
		}
		
		/**
		 * @private (protected)
		 */
		protected function drawLayout():void {
			if(background && logo && logoDivider) {
				background.width = width;
				background.height = height;
				logo.y = Math.ceil((height - logo.height) / 2);
				logo.visible = showZoomifyButton;
				logoDivider.x = logo.width;
				logoDivider.height = height;
				logoDivider.visible = showZoomifyButton;
				drawLayoutContent();
				var logoWidth:Number = showZoomifyButton ? Math.ceil(logo.width + logoDivider.width) : 0;
				content.x = logoWidth + Math.ceil((width - logoWidth - contentWidth) / 2);
			}
		}
		
		/**
		 * @private (protected)
		 */
		protected function drawLayoutContent():void {
			var dx:Number = 0;
			drawLayoutButton(zoomOut, dx);
			dx += 15 + _toolbarSpacing;
			if(showSlider) {
				dx += 3;
				slider.width = 116;
				slider.x = dx;
				slider.y = Math.floor((height - slider.height) / 2);
				dx += 116 + _toolbarSpacing + 3;
			}
			slider.visible = showSlider;
			drawLayoutButton(zoomIn, dx);
			dx += 15 + _toolbarSpacing;
			zoomPanDivider.height = height;
			zoomPanDivider.x = dx;
			dx += zoomPanDivider.width + _toolbarSpacing;
			drawLayoutButton(panLeft, dx);
			dx += 15 + _toolbarSpacing;
			drawLayoutButton(panUp, dx);
			dx += 15 + _toolbarSpacing;
			drawLayoutButton(panDown, dx);
			dx += 15 + _toolbarSpacing;
			drawLayoutButton(panRight, dx);
			dx += 15 + _toolbarSpacing;
			drawLayoutButton(reset, dx);
			contentWidth = dx + 15;
		}

		/**
		 * @private (protected)
		 */
		protected function drawLayoutButton(btn:Button, x:Number):void {
			if (btn == null) { return; }
			btn.height = 15;
			btn.width = 15;
			btn.x = x;
			btn.y = Math.floor((height - 15) / 2);
		}
		
		/**
		 * @private (protected)
		 */
		protected function initializeStageMouseListeners(event:Event = null):void {
			if(stage == null) {
				// Wait for stage to initialize;
				addEventListener(Event.ADDED_TO_STAGE, initializeStageMouseListeners, false, 0, true);
			} else {
				removeEventListener(Event.ADDED_TO_STAGE, initializeStageMouseListeners);
			}
		}
				
		protected function loadToolbarSkinXML() {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadToolbarSkinXMLCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadToolbarSkinXMLIOErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadToolbarSkinXMLIOErrorHandler);
			loader.load(new URLRequest(_toolbarSkinXMLPath));
		}
		
		protected function loadToolbarSkinXMLCompleteHandler(event:Event):void {
			if(_viewer) {
				if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarSkinXMLLoadingComplete")); }
			}
			var loader:URLLoader = event.target as URLLoader;
			var xml:XML = new XML(loader.data);
			toolbarSkinArray[0] = toolbarSkinFolderPath + xml.@SKIN0;
			toolbarSkinArray[1] = toolbarSkinFolderPath + xml.@SKIN1;
			toolbarSkinArray[2] = toolbarSkinFolderPath + xml.@SKIN2;
			toolbarSkinArray[3] = toolbarSkinFolderPath + xml.@SKIN3;
			toolbarSkinArray[4] = toolbarSkinFolderPath + xml.@SKIN4;
			toolbarSkinArray[5] = toolbarSkinFolderPath + xml.@SKIN5;
			toolbarSkinArray[6] = toolbarSkinFolderPath + xml.@SKIN6;
			toolbarSkinArray[7] = toolbarSkinFolderPath + xml.@SKIN7;
			toolbarSkinArray[8] = toolbarSkinFolderPath + xml.@SKIN8;
			toolbarSkinArray[9] = toolbarSkinFolderPath + xml.@SKIN9;
			toolbarSkinArray[10] = toolbarSkinFolderPath + xml.@SKIN10;
			toolbarSkinArray[11] = toolbarSkinFolderPath + xml.@SKIN11;
			toolbarSkinArray[12] = toolbarSkinFolderPath + xml.@SKIN12;
			toolbarSkinArray[13] = toolbarSkinFolderPath + xml.@SKIN13;
			toolbarSkinArray[14] = toolbarSkinFolderPath + xml.@SKIN14;
			toolbarSkinArray[15] = toolbarSkinFolderPath + xml.@SKIN15;
			toolbarSkinArray[16] = toolbarSkinFolderPath + xml.@SKIN16;
			toolbarSkinArray[17] = toolbarSkinFolderPath + xml.@SKIN17;
			toolbarSkinArray[18] = toolbarSkinFolderPath + xml.@SKIN18;
			toolbarSkinArray[19] = toolbarSkinFolderPath + xml.@SKIN19;
			toolbarSkinArray[20] = toolbarSkinFolderPath + xml.@SKIN20;
			toolbarSkinArray[21] = toolbarSkinFolderPath + xml.@SKIN21;
			toolbarSkinArray[22] = toolbarSkinFolderPath + xml.@SKIN22;
			toolbarSkinArray[23] = toolbarSkinFolderPath + xml.@SKIN23;
			toolbarSkinArray[24] = toolbarSkinFolderPath + xml.@SKIN24;
			toolbarSkinArray[25] = toolbarSkinFolderPath + xml.@SKIN25;
			toolbarSkinArray[26] = toolbarSkinFolderPath + xml.@SKIN26;
			toolbarSkinArray[27] = toolbarSkinFolderPath + xml.@SKIN27;
			toolbarSkinArray[28] = toolbarSkinFolderPath + xml.@SKIN28;
			toolbarSkinArray[29] = toolbarSkinFolderPath + xml.@SKIN29;
			toolbarSkinLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadToolbarSkinCompleteHandler);
			toolbarSkinLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadToolbarSkinIOErrorHandler);
			toolbarSkinLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadToolbarSkinIOErrorHandler);
			toolbarSkinLoader.contentLoaderInfo.addEventListener(Event.UNLOAD, loadToolbarSkinUnloadHandler);
			loadToolbarSkin(toolbarSkinCounter);
		}

		protected function loadToolbarSkin(counter):void {	
			toolbarSkinLoader.load(new URLRequest(toolbarSkinArray[counter]));
		}

		protected function loadToolbarSkinXMLIOErrorHandler(event:Event):void {
			skinError = Resources.ALERT_SETTINGTOOLBARSKIN;
			if(_viewer) {
				if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarSkinXMLLoadingFailed")); }
			}
			cleanupSkin();	
			configSkin();
		}

		protected function loadToolbarSkinUnloadHandler(event:Event):void {	
			if(toolbarSkinCounter < toolbarSkinCounterMax) {
				toolbarSkinCounter += 1;
				loadToolbarSkin(toolbarSkinCounter);
			} else {
				if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarSkinLoadingComplete")); }
				toolbarSkinLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadToolbarSkinCompleteHandler);
				toolbarSkinLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadToolbarSkinIOErrorHandler);
				toolbarSkinLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadToolbarSkinIOErrorHandler);
				toolbarSkinLoader.contentLoaderInfo.removeEventListener(Event.UNLOAD, loadToolbarSkinUnloadHandler);
				configSkin();
			}
		}

		protected function loadToolbarSkinCompleteHandler(event:Event):void {
			toolbarSkinLoadedArray[toolbarSkinCounter] = toolbarSkinLoader.content;
			toolbarSkinLoader.unload();
		}

		protected function loadToolbarSkinIOErrorHandler(event:Event):void {
			if(_viewer) {
				if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarSkinLoadingFailed")); }
			}
			var skinFileName:String = "Individual skin file not found";
			if(event.toString().indexOf("/") != -1) { skinFileName = event.toString().slice(event.toString().lastIndexOf("/") + 1, event.toString().lastIndexOf("]") - 1); } 
			showAlert("Skin file not found: " + skinFileName);
			cleanupSkin();	
		}

		protected function cleanupSkin():void {	
			toolbarSkinArray = [];
			toolbarSkinLoadedArray = [];
		}

		protected function validateShowToolbarTooltips() {
			if(_showToolbarTooltips == false) { 
				removeToolbarTooltips(); 
			}
		}

		protected function removeToolbarTooltips() {
			logo.removeEventListener(MouseEvent.MOUSE_OVER, logoRolloverHandler); 
			slider.removeEventListener(MouseEvent.MOUSE_OVER, sliderRolloverHandler); 
			removeButtonEventListener(zoomOut, zoomOutRolloverHandler);
			removeButtonEventListener(zoomIn, zoomInRolloverHandler);
			removeButtonEventListener(panLeft, panLeftRolloverHandler);
			removeButtonEventListener(panUp, panUpRolloverHandler);
			removeButtonEventListener(panDown, panDownRolloverHandler);
			removeButtonEventListener(panRight, panRightRolloverHandler);
			removeButtonEventListener(reset, resetRolloverHandler);
		}

		protected function validateSkins() {
			var isLivePreview:Boolean = (parent != null && getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent");
			if(isLivePreview && _toolbarSkinXMLPath != null && _toolbarSkinXMLPath != "" && _toolbarSkinXMLPath != "/") { 
				showAlert(Resources.ALERT_SKINSLIVEPREVIEW);
			}
			if(skinError != "") { showAlert(skinError); }
		}

		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::: GET & SET METHODS ::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public function get viewer():IZoomifyViewer {
			return _viewer;
		}

		public function set viewer(value:IZoomifyViewer):void {
			if (_viewer) { _viewer.removeEventListener("gridChanged", gridChangedHandler); }
			_viewer = value;
			if (_viewer) { _viewer.addEventListener("gridChanged", gridChangedHandler, false, 0, true); }	
		}

		[Inspectable(defaultValue="")]
		public function get viewerName():String {
			return _viewer.name;
		}

		public function set viewerName(value:String):void {
			try {
				viewer = parent.getChildByName(value) as IZoomifyViewer;
				var isLivePreview:Boolean = (parent != null && getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent");
				if(!isLivePreview && value != "" && value != null) { 
					if(viewer == null) { showAlert(Resources.ALERT_SETTINGTOOLBARVIEWER); }
				}
			} catch (error:Error) {
				throw new Error(Resources.ERROR_SETTINGVIEWER);
			}
		}

		[Inspectable(defaultValue="true")]
		public function get showSlider():Boolean {
			return _showSlider;
		}

		public function set showSlider(value:Boolean):void {
			if(_showSlider == value) { return; }
			_showSlider = value;
			invalidate(InvalidationType.SIZE);
		}

		[Inspectable(defaultValue="true")]
		public function get showZoomifyButton():Boolean {
			return _showZoomifyButton;
		}

		public function set showZoomifyButton(value:Boolean):void {
			if(_showZoomifyButton == value) { return; }
			_showZoomifyButton = value;
			invalidate(InvalidationType.SIZE);
		}

		[Inspectable(defaultValue="7")]
		public function get toolbarSpacing():Number {
			return _toolbarSpacing;
		}

		public function set toolbarSpacing(spaceInPixels:Number):void {
			_toolbarSpacing = spaceInPixels;
		}

		[Inspectable(defaultValue="")]
		public function get toolbarSkinXMLPath():String {
			return _toolbarSkinXMLPath;
		}

		public function set toolbarSkinXMLPath(skinXMLPath:String):void {
			_toolbarSkinXMLPath = skinXMLPath;
			if(_toolbarSkinXMLPath == null) { _toolbarSkinXMLPath = ""; }
			if(_toolbarSkinXMLPath.slice(0, 1) == '/') { _toolbarSkinXMLPath = _toolbarSkinXMLPath.slice(1, _toolbarSkinXMLPath.length); }
			if(_toolbarSkinXMLPath.indexOf("/") != -1) { toolbarSkinFolderPath = _toolbarSkinXMLPath.slice(0, _toolbarSkinXMLPath.lastIndexOf("/") + 1); } 
			configBegin(); 
		}	
		
		[Inspectable(defaultValue="true")]
		public function get showToolbarTooltips():Boolean {
			return _showToolbarTooltips;
		}

		public function set showToolbarTooltips(value:Boolean):void {
			_showToolbarTooltips = value;
		}

		/**
		 * @private (protected)
		 */
		protected function getToolbarSliderZoomDecimal():Number {	
			if(slider && (isNaN(minZoomDecimal) || isNaN(maxZoomDecimal))) { setToolbarSliderZoomDecimal(); }
			return (maxZoomDecimal - minZoomDecimal) * slider.value / 20000 + minZoomDecimal;
		}

		/**
		 * @private (protected)
		 */
		protected function setToolbarSliderZoomDecimal():void {
			if(_viewer) {
				if(_viewer.initialized) {
					var zoom:Number = _viewer.getZoomDecimal();
					minZoomDecimal = _viewer.getMinimumZoomDecimal();
					maxZoomDecimal = _viewer.getMaximumZoomDecimal();
					if(slider && !isNaN(minZoomDecimal) && !isNaN(maxZoomDecimal)) {
						slider.value = 20000 * (zoom - minZoomDecimal) / (maxZoomDecimal - minZoomDecimal);
					}
				}
			}
		}
		
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: EVENT HANDLERS :::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		/**
		 * @private (protected)
		 */
		protected function logoRolloverHandler(event:MouseEvent):void {
			Tooltip.show(Resources.TOOLTIP_LOGO, true);
			logo.addEventListener(MouseEvent.ROLL_OUT, logoRolloutHandler, false, 0, true);
		}
		/**
		 * @private (protected)
		 */
		protected function logoMouseDownHandler(event:MouseEvent):void {
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonDown")); }
			logo.addEventListener(MouseEvent.MOUSE_UP, logoMouseUpHandler, false, 0, true);
		}

		/**
		 * @private (protected)
		 */
		protected function logoMouseUpHandler(event:MouseEvent):void {
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonUp")); }
			logo.removeEventListener(MouseEvent.MOUSE_UP, logoMouseUpHandler);
			navigateToURL(new URLRequest("http://www.zoomify.com"), "_blank");
		}
		
		/**
		 * @private (protected)
		 */
		protected function logoRolloutHandler(event:MouseEvent):void {
			logo.removeEventListener(MouseEvent.ROLL_OUT, logoRolloutHandler);
			Tooltip.hide();
		}

		/**
		 * @private (protected)
		 */
		protected function zoomOutRolloverHandler(event:MouseEvent):void {
			Tooltip.show(Resources.TOOLTIP_ZOOMOUT, true);
			zoomOut.addEventListener(MouseEvent.ROLL_OUT, zoomOutRolloutHandler, false, 0, true);
		}

		/**
		 * @private (protected)
		 */
		protected function zoomOutMouseDownHandler(event:MouseEvent):void {
			prepareForUserInteraction();
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonDown")); }
			if(_viewer) {
				_viewer.zoomOut();
				addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
			}
		}

		/**
		 * @private (protected)
		 */
		protected function zoomOutRolloutHandler(event:MouseEvent):void {
			Tooltip.hide();
			if(event.buttonDown == true) { stopZoomAndPan(); }
			zoomOut.removeEventListener(MouseEvent.ROLL_OUT, zoomOutRolloutHandler);
		}

		/**
		 * @private (protected)
		 */
		protected function sliderRolloverHandler(event:MouseEvent):void {
			Tooltip.show(Resources.TOOLTIP_SLIDER, true);
			slider.addEventListener(MouseEvent.ROLL_OUT, sliderRolloutHandler, false, 0, true); 
		}

		/**
		 * @private (protected)
		 */
		protected function sliderMouseDownHandler(event:MouseEvent):void {
			prepareForUserInteraction();
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonDown")); }
			slider.addEventListener(MouseEvent.MOUSE_UP, sliderMouseUpHandler, false, 0, true); 
		}

		/**
		 * @private (protected)
		 */
		protected function sliderDragHandler(event:Event):void {
			if(_viewer) {
				if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarSliderDrag")); }
				_viewer.setExternalZoomingFlag(true);
				_viewer.setZoomDecimal(getToolbarSliderZoomDecimal(), false);
			}
		}

		/**
		 * @private (protected)
		 */
		protected function sliderChangeHandler(event:Event):void {
			if(_viewer) {
				_viewer.setExternalZoomingFlag(true);
				_viewer.setExternalZoomingFlag(false);
				_viewer.setZoomDecimal(getToolbarSliderZoomDecimal(), false);
				_viewer.invalidate(InvalidationType.STATE);
			}
		}

		/**
		 * @private (protected)
		 */
		protected function sliderMouseUpHandler(event:MouseEvent):void {
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonUp")); }
			slider.removeEventListener(MouseEvent.MOUSE_UP, sliderMouseUpHandler);
		}

		/**
		 * @private (protected)
		 */
		protected function sliderRolloutHandler(event:MouseEvent):void {
			Tooltip.hide();
			slider.removeEventListener(MouseEvent.ROLL_OUT, sliderRolloutHandler);
		}

		/**
		 * @private (protected)
		 */
		protected function zoomInRolloverHandler(event:MouseEvent):void {
			Tooltip.show(Resources.TOOLTIP_ZOOMIN, true);
			zoomIn.addEventListener(MouseEvent.ROLL_OUT, zoomInRolloutHandler, false, 0, true);
		}

		/**
		 * @private (protected)
		 */
		protected function zoomInMouseDownHandler(event:MouseEvent):void {
			prepareForUserInteraction();
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonDown")); }
			if(_viewer) {
				_viewer.zoomIn();
				addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
			}
		}

		/**
		 * @private (protected)
		 */
		protected function zoomInRolloutHandler(event:MouseEvent):void {
			Tooltip.hide();
			if(event.buttonDown == true) { stopZoomAndPan(); }
			zoomIn.removeEventListener(MouseEvent.ROLL_OUT, zoomInRolloutHandler);
		}

		/**
		 * @private (protected)
		 */
		protected function panLeftRolloverHandler(event:MouseEvent):void {
			Tooltip.show(Resources.TOOLTIP_PANLEFT, true);
			panLeft.addEventListener(MouseEvent.ROLL_OUT, panLeftRolloutHandler, false, 0, true);
		}

		/**
		 * @private (protected)
		 */
		protected function panLeftMouseDownHandler(event:MouseEvent):void {
			prepareForUserInteraction();
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonDown")); }
			if(_viewer) {
				_viewer.panLeft();
				addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
			}
		}

		/**
		 * @private (protected)
		 */
		protected function panLeftRolloutHandler(event:MouseEvent):void {
			Tooltip.hide();
			if(event.buttonDown == true) { stopZoomAndPan(); }
			panLeft.removeEventListener(MouseEvent.ROLL_OUT, panLeftRolloutHandler);
		}

		/**
		 * @private (protected)
		 */
		protected function panUpRolloverHandler(event:MouseEvent):void {
			Tooltip.show(Resources.TOOLTIP_PANUP, true);
			panUp.addEventListener(MouseEvent.ROLL_OUT, panUpRolloutHandler, false, 0, true);
		}

		/**
		 * @private (protected)
		 */
		protected function panUpMouseDownHandler(event:MouseEvent):void {
			prepareForUserInteraction();
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonDown")); }
			if(_viewer) {
				_viewer.panUp();
				addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
			}
		}

		/**
		 * @private (protected)
		 */
		protected function panUpRolloutHandler(event:MouseEvent):void {
			Tooltip.hide();
			if(event.buttonDown == true) { stopZoomAndPan(); }
			panUp.removeEventListener(MouseEvent.ROLL_OUT, panUpRolloutHandler);
		}

		/**
		 * @private (protected)
		 */
		protected function panDownRolloverHandler(event:MouseEvent):void {
			Tooltip.show(Resources.TOOLTIP_PANDOWN, true);
			panDown.addEventListener(MouseEvent.ROLL_OUT, panDownRolloutHandler, false, 0, true);
		}

		/**
		 * @private (protected)
		 */
		protected function panDownMouseDownHandler(event:MouseEvent):void {
			prepareForUserInteraction();
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonDown")); }
			if(_viewer) {
				_viewer.panDown();
				addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
			}
		}

		/**
		 * @private (protected)
		 */
		protected function panDownRolloutHandler(event:MouseEvent):void {
			Tooltip.hide();
			if(event.buttonDown == true) { stopZoomAndPan(); }
			panDown.removeEventListener(MouseEvent.ROLL_OUT, panDownRolloutHandler);
		}

		/**
		 * @private (protected)
		 */
		protected function panRightRolloverHandler(event:MouseEvent):void {
			Tooltip.show(Resources.TOOLTIP_PANRIGHT, true);
			panRight.addEventListener(MouseEvent.ROLL_OUT, panRightRolloutHandler, false, 0, true);
		}

		/**
		 * @private (protected)
		 */
		protected function panRightMouseDownHandler(event:MouseEvent):void {
			prepareForUserInteraction();
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonDown")); }
			if(_viewer) {
				_viewer.panRight();
				addEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler, false, 0, true);
			}
		}

		/**
		 * @private (protected)
		 */
		protected function panRightRolloutHandler(event:MouseEvent):void {
			Tooltip.hide();
			if(event.buttonDown == true) { stopZoomAndPan(); }
			panRight.removeEventListener(MouseEvent.ROLL_OUT, panRightRolloutHandler);
		}

		/**
		 * @private (protected)
		 */
		protected function resetRolloverHandler(event:MouseEvent):void {
			Tooltip.show(Resources.TOOLTIP_RESET, true);
			reset.addEventListener(MouseEvent.ROLL_OUT, resetRolloutHandler, false, 0, true);
		}

		/**
		 * @private (protected)
		 */
		protected function resetMouseDownHandler(event:MouseEvent):void { 
			prepareForUserInteraction();
			if(_viewer.eventsEnabled) { dispatchEvent(new Event("toolbarButtonDown")); }
			if(_viewer) { _viewer.zoomToInitialView(); } 
		}

		/**
		 * @private (protected)
		 */
		protected function resetRolloutHandler(event:MouseEvent):void {
			Tooltip.hide();
			reset.removeEventListener(MouseEvent.ROLL_OUT, resetRolloutHandler);
		}

		/**
		 * @private (protected)
		 */
		protected function gridChangedHandler(event:Event):void {
			setToolbarSliderZoomDecimal();
		}
		
		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::: CORE METHODS :::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		/**
		 * @private (protected)
		 */
		protected function stopZoomAndPan():void {
			if(_viewer) {
				_viewer.zoomStop();
				_viewer.panStop();
				_viewer.invalidate(InvalidationType.STATE);
			}
		}

		/**
		 * @private (protected)
		 */
		protected function stopZoomAndPanHandler(event:MouseEvent):void {
			if(_viewer) {
				_viewer.zoomStop();
				_viewer.panStop();
				_viewer.invalidate(InvalidationType.STATE);
				removeEventListener(MouseEvent.MOUSE_UP, stopZoomAndPanHandler);
			}
		}

		protected function removeButtonEventListener(btn:Button, rolloverHandler:Function):void {
			btn.removeEventListener(MouseEvent.MOUSE_OVER, rolloverHandler); 
		}

		/**
		 * @private (protected)
		 */
		protected function prepareForUserInteraction():void {
			// DEV NOTE: primarily used in Slideshow viewer.
		}

		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::: SUPPORT METHODS ::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			
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
		
		protected function showAlert(text:String):void {
			if(alertOverlay == null) { alertOverlay = new Sprite(); }
			while(alertOverlay.numChildren > 0) { alertOverlay.removeChildAt(0); }
			var toolbarAlertBackground:DisplayObject = getDisplayObjectInstance(getStyleValue("toolbarAlert"));
			if(toolbarAlertBackground) {
				alertOverlay.addChild(toolbarAlertBackground);
			}
			var tf:TextField = new TextField();
			tf.multiline = false;
			tf.selectable = false;
			tf.condenseWhite = true;
			tf.defaultTextFormat = new TextFormat("_sans", 12, 0x000000, null, null, null, null, null, TextFormatAlign.CENTER);
			tf.htmlText = text;
			tf.width = alertOverlay.width - 2;
			tf.height = alertOverlay.height - 2;
			tf.x = 1;
			tf.y = 1;
			alertOverlay.addChild(tf);
			alertOverlay.x = width / 2 - alertOverlay.width / 2; 
			alertOverlay.y = 1;
			addChild(alertOverlay);
			alertOverlay.visible = true;
			alertOverlay.alpha = 1;
		}
		
		protected function hideAlert():void {
			alertOverlay.visible = false;
		
		}
	}
}