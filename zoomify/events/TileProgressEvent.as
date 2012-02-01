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
	import flash.events.Event;

	public class TileProgressEvent extends Event 
	{
		public static const TILE_PROGRESS:String = "tileProgress";
		
		public var files:uint;
		public var bytesTotal:uint;
		public var bytesLoaded:uint;

		public function TileProgressEvent(type:String, files:uint, bytesTotal:uint, bytesLoaded:uint, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.files = files;
			this.bytesTotal = bytesTotal;
			this.bytesLoaded = bytesLoaded;
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event {
			return new TileProgressEvent(type, files, bytesTotal, bytesLoaded, bubbles, cancelable);
		}
		
		public override function toString():String {
			return '[Event type="' + type + '" files=' + files + ' bytesTotal=' + bytesTotal + ' bytesLoaded=' + bytesLoaded + ']';
		}
	}
}
