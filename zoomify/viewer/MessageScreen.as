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
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class MessageScreen extends MovieClip
	{
	
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::: INIT METHODS :::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

		public var tfMessage:TextField;
		
		public function MessageScreen():void {
			tfMessage = new TextField();
			tfMessage.x = 0;
			tfMessage.y = 120;
			tfMessage.width = 260;
			tfMessage.height = 120;
			tfMessage.multiline = true;
			tfMessage.selectable = false;
			tfMessage.wordWrap = true;
			tfMessage.defaultTextFormat = new TextFormat("_sans", 12, 0x000000, null, null, null, null, null, TextFormatAlign.CENTER);
			addChild(tfMessage);
		}
		
		
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::: GET & SET METHODS ::::::::::::::::::::::::::::
		//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		public function setMessage(msg:String):void {
			tfMessage.text = msg;
		}
		
		public function getMessage():String {
			return tfMessage.text;
		}
	}
}