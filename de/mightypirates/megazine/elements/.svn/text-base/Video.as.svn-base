/*
MegaZine 3 - A Flash application for easy creation of book-like webpages.
Copyright (C) 2007-2008 Florian Nuecke

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.
*/

package de.mightypirates.megazine.elements {
	
	import de.mightypirates.megazine.IMegaZine;
	import de.mightypirates.megazine.events.MegaZineEvent;
	import de.mightypirates.megazine.gui.*;
	import de.mightypirates.utils.*;
	
	import fl.video.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	/**
	 * EXTERNAL ELEMENT
	 * 
	 * The video element can be used to load and play videos. See documentation for supported
	 * formats. Uses the FLVPlayback component.
	 * 
	 * @author fnuecke
	 */
	public class Video extends AbstractElement {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** Because the one of the flvplayback gets overwritten when loading the movie */
		private var _autoStart:Boolean = true;
		
		/** Current fade state, 0 = none, 1 = in, 2 = out */
		private var _fadeState:int = 0;
		
		/** The video playback component */
		private var _flvPlayback:FLVPlayback;
		
		/** Glow effect (faded in on mouseover if image is linked) */
		private var _glow:GlowFilter;
		
		/**
		 * When loading completes, keep the current height or use the one from the loaded video?
		 */
		private var _keepHeight:Boolean = false;
		
		/**
		 * When loading completes, keep the current width or use the one from the loaded video?
		 */
		private var _keepWidth:Boolean = false;
		
		/** Currently muted even if visible? */
		private var _muted:Boolean = false;
		
		/** Do not pause when the containing page becomes invisible */
		private var _noPause:Boolean = false;
		
		/** Page visible? */
		private var _pageVisible:Boolean = false;
		
		/** Playstate before the page became invisible */
		private var _prevPlayState:Boolean = false;
		
		/** Current target alpha for the glow */
		private var _targetGlowAlpha:Number = 0;
		
		/** Volume set in the flvplayback (maybe changed by user, so remember) */
		private var _volFLVPlayback:Number = 1.0;
		
		/** The currently targeted volume */
		private var _volTarget:Number = 0;
		
		/** Timer to increase or decrease volume if needed */
		private var _volTimer:Timer;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		public function Video() {
			
			// Create the playback component
			_flvPlayback = new FLVPlayback();
			
			// Hide initially, until we know real sizes.
			_flvPlayback.visible = false;
			
			// Disable takeover in fullscreen mode
			_flvPlayback.fullScreenTakeOver = false;
			
			// Replay automatically
			_flvPlayback.autoRewind = true;
			
			// Add it to the stage
			addChild(_flvPlayback);
			
			// For cleanup
			addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * The specialized init method, the would be constructor for the element.
		 * Should be overwritten for every element to process the xml data.
		 */
		override public function init():void {
			try {
				_volTimer = new Timer(Helper.validateUInt(_xml.@fade, 2000) / 20);
				// Register volume handling event with timer
				_volTimer.addEventListener(TimerEvent.TIMER, onTimer);
				
				// Pause when hidden override
				_noPause = Helper.validateBoolean(_xml.@nopause, false);
				
				// Setup glow filter
				if (_xml.@url != undefined && Helper.validateBoolean(_xml.@useglow, true))
				{
					var size:int = int(Math.min(_flvPlayback.width, _flvPlayback.height) / 10);
					_glow = new GlowFilter(0xFFFFFF, 0, size, size, 1,
										   BitmapFilterQuality.MEDIUM, true);
					var t:Timer = new Timer(25);
					t.addEventListener(TimerEvent.TIMER,
						function(e:TimerEvent):void {
							if (Math.abs(_glow.alpha - _targetGlowAlpha) <= 0.1) {
								// Close enough, set it.
								t.stop();
								_glow.alpha = _targetGlowAlpha;
								if (_targetGlowAlpha == 0) {
									_flvPlayback.filters = null;
									return;
								}
							} else {
								// Adjust the alpha.
								_glow.alpha += (_glow.alpha < _targetGlowAlpha) ? 0.1 : -0.1;
							}
							_flvPlayback.filters = [_glow];
						});
					addEventListener(MouseEvent.MOUSE_OVER,
						function(e:MouseEvent):void {
							_targetGlowAlpha = 1;
							t.start();
							
						});
					addEventListener(MouseEvent.MOUSE_OUT,
						function(e:MouseEvent):void {
							_targetGlowAlpha = 0;
							t.start();
						});
				}
				
				// Setup video
				_autoStart = Helper.validateBoolean(_xml.@autoplay, true);
				
				var tmpWidth:int = Helper.validateInt(_xml.@width, 0);
				if (tmpWidth > 0) {
					_flvPlayback.width = tmpWidth;
					_keepWidth = true;
				}
				var tmpHeight:int = Helper.validateInt(_xml.@height, 0);
				if (tmpHeight > 0) {
					_flvPlayback.height = tmpHeight;
					_keepHeight = true;
				}
				
				if (_xml.@src != undefined && _xml.@src.toString() != "") {
					var url:String = _mz.getAbsPath(_xml.@src.toString());
					// Handle loading errors
					_flvPlayback.addEventListener(VideoEvent.STATE_CHANGE,
						function(e:VideoEvent):void {
							if (_flvPlayback.state == VideoState.CONNECTION_ERROR) {
								Logger.log("MegaZine Video",
										   "    Error loading video: "
										   + Helper.trimString(url, 40)
										   + " in page " + (_page.getNumber(_even) + 1),
										   Logger.TYPE_WARNING);
								removeChild(_loading);
								dispatchEvent(new MegaZineEvent(MegaZineEvent.ELEMENT_COMPLETE,
																_page.getNumber(_even)));
							}
						});
					// Handle loading done
					_flvPlayback.addEventListener(VideoEvent.READY, onReady);
					// Auto replay
					_flvPlayback.addEventListener(Event.COMPLETE,
						function(e:Event):void {
							_flvPlayback.play();
						});
					try {
						new URLRequest(url);
						_flvPlayback.load(url);
					} catch (ex:Error) {
						Logger.log("MegaZine Video",
								   "    Error loading video: " + Helper.trimString(url, 40)
								   + " in page " + (_page.getNumber(_even) + 1),
								   Logger.TYPE_WARNING);
						super.init();
					}
				} else {
				}
			} catch (e:Error) {
				Logger.log("MegaZine Video",
						   "    Failed setting up 'vid' object in page "
						   + (_page.getNumber(_even) + 1),
						   Logger.TYPE_WARNING);
				super.init();
			}
		}
		
		/**
		 * Video loaded completely, set it up.
		 * @param	e
		 */
		private function onReady(e:VideoEvent):void {
			if (!_keepWidth) {
				_flvPlayback.width = _flvPlayback.preferredWidth;
			}
			if (!_keepHeight) {
				_flvPlayback.height = _flvPlayback.preferredHeight;
			}
			_flvPlayback.visible = true;
			_prevPlayState = _autoStart;
			_flvPlayback.autoPlay = _autoStart;
			if (_flvPlayback.autoPlay && _noPause) {
				_flvPlayback.play();
			}
			var s:Sprite = new Sprite();
			
			// To allow mouse events... it seems flvplayback does not support them.
			s.graphics.beginFill(0, 0);
			s.graphics.drawRect(0, 0, _flvPlayback.width, _flvPlayback.height);
			s.graphics.endFill();
			addChildAt(s, 0);
			
			// Update glowfilter size
			if (_glow != null) {
				_glow.blurX = _glow.blurY = int(Math.min(_flvPlayback.width,
														 _flvPlayback.height) / 10);
			}
			
			// Set the gui
			if (_xml.@gui != undefined && _xml.@gui.toString() != "") {
				var gui:String = _mz.getAbsPath(_xml.@gui.toString());
				var guicolor:uint = Helper.validateUInt(_xml.@guicolor, 0xFF333333);
				var guialpha:Number = ((guicolor >>> 24) == 0) ? 0.75 : ((guicolor >>> 24) / 255.0);
				try {
					_flvPlayback.skin = gui;
					_flvPlayback.skinBackgroundColor = (0xFFFFFF & guicolor);
					_flvPlayback.skinBackgroundAlpha = guialpha;
				} catch (ex:Error) {
					Logger.log("MegaZine Video",
							   "    Error loading video gui '" + Helper.trimString(gui, 40)
							   + "' in page " + (_page.getNumber(_even) + 1),
							   Logger.TYPE_WARNING);
				}
			}
			
			if (_even) {
				_page.addEventListener(MegaZineEvent.INVISIBLE_EVEN, onInvisible);
				_page.addEventListener(MegaZineEvent.VISIBLE_EVEN, onVisible);
			} else {
				_page.addEventListener(MegaZineEvent.INVISIBLE_ODD, onInvisible);
				_page.addEventListener(MegaZineEvent.VISIBLE_ODD, onVisible);
			}
			
			// Register for mute / unmute events.
			_mz.addEventListener(MegaZineEvent.MUTE, onMute);
			_mz.addEventListener(MegaZineEvent.UNMUTE, onUnmute);
			
			// Done
			super.init();
			
			// If the page is visible: start
			if (_page.getPageVisible(_even)) {
				_prevPlayState = true;
				onVisible();
			}
			
			// Get current mute state from the megazine
			if (_mz.muted) {
				onMute(null);
			}
			
		}
		
		/**
		 * When removed from stage do some cleanup
		 * @param	e
		 */
		private function removeListeners(e:Event):void {
			if (_even) {
				_page.removeEventListener(MegaZineEvent.INVISIBLE_EVEN, onInvisible);
				_page.removeEventListener(MegaZineEvent.VISIBLE_EVEN, onVisible);
			} else {
				_page.removeEventListener(MegaZineEvent.INVISIBLE_ODD, onInvisible);
				_page.removeEventListener(MegaZineEvent.VISIBLE_ODD, onVisible);
			}
			
			// Register for mute / unmute events.
			_mz.removeEventListener(MegaZineEvent.MUTE, onMute);
			_mz.removeEventListener(MegaZineEvent.UNMUTE, onUnmute);
			
			removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			
			_volTimer.stop();
			
			// Must be set to false, else garbage collection won't kick in!
			_flvPlayback.skinAutoHide = false;
			_flvPlayback.stop();
		}
		
		/**
		 * Triggers required actions when the containing page becomes visible
		 * (start playback if autopaused, fade in volume)
		 * @param e not used.
		 */
		function onInvisible(e:MegaZineEvent):void {
			_pageVisible = false;
			_prevPlayState = _flvPlayback.playing;
			if (_fadeState == 0 && !_muted) _volFLVPlayback = _flvPlayback.volume;
			_fadeState = 2;
			_volTarget = 0;
			if (_volTimer.delay > 0) {
				_volTimer.start();
			} else {
				onTimer();
			}
		}
		
		/**
		 * Triggers required actions when the containing page becomes invisible
		 * (autopausing playback if not forbidden, fade out volume)
		 * @param e not used.
		 */
		function onVisible(e:MegaZineEvent = null):void {
			_pageVisible = true;
			if (!_noPause && _prevPlayState) _flvPlayback.play();
			_fadeState = 1;
			_volTarget = _muted ? 0 : _volFLVPlayback;
			if (_volTimer.delay > 0) {
				_volTimer.start();
			} else {
				onTimer();
			}
		}
		
		/**
		 * Takes care of fading the volume, triggered by a timer.
		 * @param e unused.
		 */
		function onTimer(e:TimerEvent = null):void {
			_flvPlayback.volume += _flvPlayback.volume < _volTarget ? 0.05 : -0.05;
			if (Math.abs(_flvPlayback.volume - _volTarget) < 0.1) {
				_flvPlayback.volume = _volTarget;
				if (!_noPause && _fadeState == 2) {
					_flvPlayback.pause();
				}
				_fadeState = 0;
				_volTimer.stop();
			}
		}
		
		/**
		 * Muted
		 * @param	e
		 */
		function onMute(e:MegaZineEvent):void {
			if (_fadeState > 0) {
				_volTarget = 0;
			} else if (_pageVisible) {
				_volFLVPlayback = _flvPlayback.volume;
			}
			_flvPlayback.volume = 0;
			_muted = true;
		}
		
		/**
		 * Unmuted
		 * @param	e
		 */
		function onUnmute(e:MegaZineEvent):void {
			if (_pageVisible) {
				_flvPlayback.volume = _volFLVPlayback;
			}
			_muted = false;
		}
		
	}
	
}
