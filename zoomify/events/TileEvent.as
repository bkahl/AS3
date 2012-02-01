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

package zoomify.events
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import zoomify.viewer.TileDataLoader;

	public class TileEvent extends Event 
	{
		public static const READY:String = "ready";
		public static const REMOVED:String = "removed";
		
		public var t:uint;
		public var r:uint;
		public var c:uint;
		public var bmp:Bitmap;
		public var loader:TileDataLoader;

		public function TileEvent(type:String, loader:TileDataLoader, bitmap:Bitmap, t:uint, r:uint, c:uint, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.loader = loader;
			bmp = bitmap;
			this.t = t;
			this.r = r;
			this.c = c;
			super(type, bubbles, cancelable);
		}
		
	}
}
