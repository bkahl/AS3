﻿package com.erikhallander.pixels{		import flash.display.Bitmap;	import flash.display.Sprite;	import flash.display.BitmapData;	import flash.display.PixelSnapping;	/* Takes a bitmap and attaches it to a sprite */		public class pixel extends Sprite {				public var origX:int;		public var origY:int;		public var tox:Number;		public var toy:Number;		public var xcount:Number = 0;		public var ycount:Number = 0;		public var step:Number = Math.random() * 0.5;		public var rad:Number = Math.round(Math.random() * 5);				public function pixel(_bitmapData:BitmapData, _origX:int, _origY:int) {			addChild(new Bitmap(_bitmapData, PixelSnapping.ALWAYS));			origX = _origX;			origY = _origY;		}	}}