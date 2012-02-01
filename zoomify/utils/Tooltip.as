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
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import zoomify.IZoomifyViewer;
	
	public class Tooltip
	{
		
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: INIT METHODS :::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		protected static var tooltip:Sprite;
		protected static var delayTimer:Timer;
		protected static var fadeIn:Boolean;
		protected static var viewerRef:IZoomifyViewer;
		
		public function Tooltip():void {}
		
		public static function initialize(viewer:IZoomifyViewer):void {
			if(tooltip == null) {
				tooltip = new Sprite();
				tooltip.visible = false;
				Sprite(viewer).stage.addChild(tooltip);
				viewerRef = viewer;
			}
		}
				
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::: INTERACTION METHODS ::::::::::::::::::::::::::
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public static function show(text:String, delayVisibility:Boolean = false):void {
			if(tooltip != null) {
				while(tooltip.numChildren > 0) { tooltip.removeChildAt(0); }
				var tf:TextField = new TextField();
				var tfo:TextFormat = new TextFormat("_sans", 12, 0x000000, false, false, false, null, null, TextFormatAlign.LEFT);
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.multiline = true;
				tf.selectable = false;
				tf.condenseWhite = true;
				tf.defaultTextFormat = tfo;
				tf.htmlText = text;
				tf.x = 4;
				tf.y = 1;
				var tooltipBackground:DisplayObject = viewerRef.getTooltipBackground();
				if(tooltipBackground) {
					tooltipBackground.width = tf.width + 8;
					tooltipBackground.height = tf.height + 2;
					tooltip.addChild(tooltipBackground);
				}
				tooltip.addChild(tf);
				var stage:Stage = tooltip.stage;
				var w:Number = tooltip.width;
				var h:Number = tooltip.height;
				var pt:Point = new Point(stage.mouseX + 18, stage.mouseY + 18);
				if(pt.y + h > stage.stageHeight) {
					pt.y = stage.mouseY - h - 3;
					pt.x = stage.mouseX + 3;
				}
				if(pt.x + w > stage.stageWidth) {
					pt.x = stage.mouseX - w - 3;
				}
				tooltip.x = pt.x;
				tooltip.y = pt.y;
				if(delayVisibility) {
					hide();
					delayTimer = new Timer(1000, 1);
					delayTimer.addEventListener("timer", delayTimerHandler, false, 0, true);
					delayTimer.start();
				} else {
					tooltip.visible = true;
				}
			}
		}
		
		public static function delayTimerHandler(event:TimerEvent):void {
			tooltip.visible = true;
		}
		
		public static function hide():void {
			if(tooltip != null) {
				if(delayTimer) {
					if(delayTimer.running) { delayTimer.stop(); }
				}
				tooltip.visible = false;
			}
		}
	}
}
