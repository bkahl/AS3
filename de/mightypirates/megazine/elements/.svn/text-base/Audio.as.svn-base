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
	
	import de.mightypirates.megazine.*;
	import de.mightypirates.megazine.events.*;
	import de.mightypirates.megazine.gui.ILibrary;
	import de.mightypirates.utils.*;
	
	import flash.events.*;
	import flash.media.*;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	/**
	 * The sound class is used to load sounds into pages.
	 * 
	 * @author fnuecke
	 */
	public class Audio extends AbstractElement {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The delay in milliseconds to wait before starting the sound */
		private var _delay:Number = 2000;
		
		/** Value by which to change the volume each timer tick */
		private var _increment:Number = 0.05;
		
		/** Is the sound _muted even when visible? */
		private var _muted:Boolean = false;
		
		/** The sound that should be played */
		private var _sound:Sound;
		
		/** The soundchannel of the currently playing sound (necessary for volume adjustments) */
		private var _soundChannel:SoundChannel;
		
		/** Sound transform for the sound channel (the volume adjustment) */
		private var _soundTrans:SoundTransform;

		/** The currently targeted volume */
		private var _volTarget:Number = 0;
		
		/** Timer to increase or decrease volume if needed */
		private var _volTimer:Timer;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new sound object, which in turn loads a sound an plays it while its containing
		 * page is visible.
		 * @param mz The container megazine.
		 * @param lib The library to obtain gui graphics from.
		 * @param page The container page.
		 * @param even Even or odd part of the page object.
		 * @param xml XML data for the sound object.
		 */
		public function Audio(mz:IMegaZine, loc:Localizer, lib:ILibrary,
							  page:IPage, even:Boolean, xml:XML)
		{
			super(mz, loc, lib, page, even, xml);
			_sound = new Sound();
			_soundTrans = new SoundTransform(0);
			_volTimer = new Timer(100);
		}
		
		/**
		 * Initialize loading.
		 */
		override public function init():void {
			// Load the sound
			var url:String = Helper.validateString(_xml.@src, "");
			if (url != "") {
				
				url = _mz.getAbsPath(url);
				
				// Register volume handling event with timer
				_volTimer.addEventListener(TimerEvent.TIMER, onTimer);
				// Check for custom fading time
				var fade:int = Helper.validateInt(_xml.@fade, -1);
				if (fade >= 0) {
					if (fade == 0) {
						_increment = -1;
					} else {
						_increment = _volTimer.delay / fade;
					}
				}
				_delay = Helper.validateUInt(_xml.@delay, 2000);
				
				// Handle loading errors
				_sound.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						Logger.log("MegaZine Audio",
								   "    Error loading sound: " + Helper.trimString(url, 40)
								   + " in page " + (_page.getNumber(_even) + 1),
								   Logger.TYPE_WARNING);
						removeChild(_loading);
						dispatchEvent(new MegaZineEvent(MegaZineEvent.ELEMENT_COMPLETE,
														_page.getNumber(_even)));
					});
				
				// Handle successful loading
				_sound.addEventListener(Event.COMPLETE, onComplete);
				
				try {
					
					// Begin loading
					_sound.load(new URLRequest(url));
					
				} catch (ex:Error) {
					Logger.log("MegaZine Audio",
							   "    Error loading sound: " + Helper.trimString(url, 40)
							   + " in page " + (_page.getNumber(_even) + 1),
							   Logger.TYPE_WARNING);
					super.init();
				}
				
			} else {
				Logger.log("MegaZine Audio", "    No source defined for 'snd' object in page "
							+ (_page.getNumber(_even) + 1), Logger.TYPE_WARNING);
				super.init();
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Methods
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Sound loading complete, begin playback.
		 * @param e
		 */
		private function onComplete(e:Event):void {
			registerListeners();
			// Register with megazine onMute and onUnmute events.
			_mz.addEventListener(MegaZineEvent.MUTE, onMute);
			_mz.addEventListener(MegaZineEvent.UNMUTE, onUnmute);
			super.init();
			onSoundComplete();
			// If the page is visible: make audible
			if (_page.getPageVisible(_even)) {
				onVisible();
			}
			if (_mz.muted) {
				onMute(null);
			}
		}
		
		/**
		 * Sound completed playback, restart it for infinite loop.
		 * @param	e
		 */
		private function onSoundComplete(e:Event = null):void {
			// Remove listener from old sound channel
			if (_soundChannel) {
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
			// Get new one by restarting playback
			_soundChannel = _sound.play();
			_soundChannel.soundTransform = _soundTrans;
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		/**
		 * Sound should be muted
		 * @param	e
		 */
		private function onMute(e:MegaZineEvent):void {
			_muted = true;
			try {
				_volTimer.reset();
				_soundTrans.volume = 0;
				_soundChannel.soundTransform = _soundTrans;
			} catch (e:Error) {}
		}
		
		/**
		 * Unmute sound
		 * @param	e
		 */
		private function onUnmute(e:MegaZineEvent):void {
			_muted = false;
			try {
				_soundTrans.volume = _volTarget;
				_soundChannel.soundTransform = _soundTrans;
			} catch (e:Error) {}
		}
		
		/**
		 * Restore sound when visible (and not muted)
		 * @param	e
		 */
		private function onInvisible(e:MegaZineEvent):void {
			_volTarget = 0;
			if (_muted) return;
			if (_increment > 0) {
				_volTimer.start();
			} else {
				onTimer();
			}
		}
		
		/**
		 * Make inaudible when page gets hidden.
		 * @param	e
		 */
		private function onVisible(e:MegaZineEvent = null):void {
			_volTarget = 1;
			if (_muted) return;
			if (_increment > 0) {
				_volTimer.start();
			} else {
				onTimer();
			}
		}
		
		/**
		 * Update volume level (volume fader)
		 * @param	e
		 */
		private function onTimer(e:TimerEvent = null):void {
			if (_soundTrans.volume < _volTarget) {
				// Fading in
				if (_soundTrans.volume == 0 && _volTimer.currentCount * _volTimer.delay < _delay) return;
				_soundTrans.volume += _increment;
			} else {
				// Fading out
				_soundTrans.volume -= _increment;
			}
			if (_increment <= 0
				|| Math.abs(_soundTrans.volume - _volTarget) <= _increment)
			{
				_soundTrans.volume = _volTarget;
				_volTimer.reset();
			}
			_soundChannel.soundTransform = _soundTrans;
		}
		
		/**
		 * Register event listeners (done when sound was loaded completely)
		 */
		private function registerListeners():void {
			if (_even) {
				_page.addEventListener(MegaZineEvent.INVISIBLE_EVEN, onInvisible);
				_page.addEventListener(MegaZineEvent.VISIBLE_EVEN, onVisible);
			} else {
				_page.addEventListener(MegaZineEvent.INVISIBLE_ODD, onInvisible);
				_page.addEventListener(MegaZineEvent.VISIBLE_ODD, onVisible);
			}
			addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
		}
		
		/**
		 * Removes all event listeners, kills the sound (when removed from stage).
		 */
		private function removeListeners():void {
			if (_even) {
				_page.removeEventListener(MegaZineEvent.INVISIBLE_EVEN, onInvisible);
				_page.removeEventListener(MegaZineEvent.VISIBLE_EVEN, onVisible);
			} else {
				_page.removeEventListener(MegaZineEvent.INVISIBLE_ODD, onInvisible);
				_page.removeEventListener(MegaZineEvent.VISIBLE_ODD, onVisible);
			}
			removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			_soundChannel.stop();
			_sound.close();
		}
		
	}
	
}
