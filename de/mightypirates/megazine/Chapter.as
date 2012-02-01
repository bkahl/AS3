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

package de.mightypirates.megazine {
	
	import de.mightypirates.megazine.events.MegaZineEvent;
	import de.mightypirates.utils.*;
	
	import flash.events.*;
	import flash.media.*;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	/**
	 * Holds data for a chapter in the book (page default values). This is created for easier
	 * propagation of inheritable properties, such as background color and folding effect
	 * strength.
	 * It is also used to handle the sound playback that may be defined for chapters.
	 * 
	 * @author fnuecke
	 */
	internal class Chapter {
		
		// ----------------------------------------------------------------------------------- //
		// Variables
		// ----------------------------------------------------------------------------------- //
		
		/** The default background color for this chapter */
		private var _bgColor:uint;
		
		/** The default foldfx alpha for this chapter */
		private var _foldFX:Number;
		
		/** Pages that this chapter will register itself with */
		private var _markedPages:Array; // int, page numbers
		
		/** Array listing the visible and invisible states of pages */
		private var _visible:Array; // Boolean, at index of page number
		
		
		/** Slide show delay for pages in this chapter */
		private var _slideDelay:uint;
		
		
		/** Delay before fading in the sound */
		private var _delay:Number = 2000;
		
		/** Background sound for this chapter */
		private var _sound:Sound;
		
		/** The soundchannel of the currently playing sound (necessary for volume adjustments) */
		private var _soundChannel:SoundChannel;
		
		/** Sound transform for the sound channel (the volume adjustment) */
		private var _soundTrans:SoundTransform;

		/** The currently targeted volume */
		private var _volTarget:Number = 0;
		
		/** Timer to increase or decrease volume if needed */
		private var _volTimer:Timer;
		
		/** Value by which to change the volume each timer tick */
		private var _increment:Number = 0.05;
				
		/** Is the sound muted even when pages of the chapter visible? */
		private var _muted:Boolean = false;
		
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new chapter.
		 * @param mz The megazine this chapter belongs to.
		 */
		public function Chapter(mz:MegaZine, chapterXML:XML, number:int,
								bgColor:uint, foldFX:Number, slideDelay:uint) {
			
			// Initialize variables.
			_markedPages = new Array();
			_visible     = new Array();
			_volTimer    = new Timer(100);
			_soundTrans  = new SoundTransform(0);
			
			// Background color.
			_bgColor = Helper.validateUInt(chapterXML.@bgcolor, bgColor);
			
			// Folding effects alpha value.
			_foldFX = Helper.validateNumber(chapterXML.@foldfx, foldFX, 0, 1);
			
			// Time in ms to show a page before turning to the next one in seconds.
			_slideDelay = Helper.validateUInt(chapterXML.@slidedelay, slideDelay, 1);
			
			// Background sound
			var url:String = Helper.validateString(chapterXML.@bgsound, "");
			if (url != "") {
				
				url = mz.getAbsPath(url);
				
				// Check for custom fading time
				if (chapterXML.@fade != undefined && int(chapterXML.@fade.toString()) >= 0) {
					if (int(chapterXML.@fade.toString()) == 0) {
						_increment = -1;
					} else {
						_increment = _volTimer.delay / uint(chapterXML.@fade.toString());
					}
				}
				_delay = Helper.validateUInt(chapterXML.@delay, 2000);
				
				// Create the sound object.
				_sound = new Sound();
				
				// Register volume handling event with timer
				_volTimer.addEventListener(TimerEvent.TIMER, onTimer);
				
				// Handle loading errors
				_sound.addEventListener(IOErrorEvent.IO_ERROR,
					function(e:IOErrorEvent):void {
						_sound = null;
						Logger.log("MegaZine Chapter", "    Error loading sound: "
													   + Helper.trimString(url, 30)
													   + " for chapter " + number,
								   Logger.TYPE_WARNING);
					});
				
				// Loading completion handling
				_sound.addEventListener(Event.COMPLETE, onSoundComplete);
				
				try {
					
					// Begin loading
					_sound.load(new URLRequest(url));
					
				} catch (ex:Error) {
					_sound = null;
					Logger.log("MegaZine Chapter", "    Error loading sound: "
												   + Helper.trimString(url, 30)
												   + " for chapter " + number,
							   Logger.TYPE_WARNING);
				}
				
			}
			
			// Register for muting events (here and not in the sound loaded part so we
			// do not need to remember the megazine variable).
			mz.addEventListener(MegaZineEvent.MUTE, onMute);
			mz.addEventListener(MegaZineEvent.UNMUTE, onUnmute);
			
			// Set initially to muted if the megazine is muted.
			if (mz.muted) onMute(null);
		}
		
		/**
		 * Adds a page to this chapter. This marks the page for registration when the method
		 * registerEvents is called.
		 * @param page The page number of the page to add.
		 */
		internal function addPage(page:int):void {
			_markedPages.push(page);
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Event handling
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Mute sound
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
		 * A page in this chapter became visible.
		 * @param e Event object.
		 */
		private function onVisible(e:MegaZineEvent):void {
			// If no sound is defined, kill listeners
			if (_sound == null) {
				e.target.removeEventListener(e.type, onVisible);
			}
			
			_visible[e.page] = true;
			
			_volTarget = 1;
			if (_muted) return;
			if (_increment > 0) {
				_volTimer.start();
			} else {
				onTimer();
			}
		}
		
		/**
		 * A page in the chapter became invisible.
		 * @param e Event object.
		 */
		private function onInvisible(e:MegaZineEvent):void {
			// If no sound is defined, kill listeners
			if (_sound == null) {
				e.target.removeEventListener(e.type, onInvisible);
			}
			
			_visible[e.page] = false;
			
			// Check if all pages are invisible.
			var vis:Boolean = false;
			for each (var b:Boolean in _visible) {
				vis ||= b;
			}
			
			if (!vis) {
				_volTarget = 0;
				if (_muted) return;
				if (_increment > 0) {
					_volTimer.start();
				} else {
					onTimer();
				}
			}
		}
		
		/**
		 * Handle sound complete event to restart the sound.
		 * @param e Event object.
		 */
		private function onSoundComplete(e:Event = null):void {
			// Avoid nullpointers...
			if (_sound == null) {
				return;
			}
			_soundChannel = _sound.play();
			_soundChannel.soundTransform = _soundTrans;
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		/**
		 * Handle volume change timer event.
		 * @param e Event object (unused).
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
		 * Registers the chapter with all marked pages for visibility and invisibilty events,
		 * to fade chapter wide background sounds.
		 * @param pages The array of page objects to use when registering for events.
		 */
		internal function registerEvents(pages:Array):void {
			// Only necessary if a background sound is specified.
			if (_sound == null) {
				return;
			}
			for each (var page:int in _markedPages) {
				// Odd or even page...
				if ((page & 1) == 0) {
					pages[page].addEventListener(MegaZineEvent.INVISIBLE_EVEN, onInvisible);
					pages[page].addEventListener(MegaZineEvent.VISIBLE_EVEN, onVisible);
				} else {
					pages[page].addEventListener(MegaZineEvent.INVISIBLE_ODD, onInvisible);
					pages[page].addEventListener(MegaZineEvent.VISIBLE_ODD, onVisible);
				}
			}
		}
		
		
		// ----------------------------------------------------------------------------------- //
		// Getters
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Get the default page background color for this chapter.
		 * @return Background color for the chapter.
		 */
		internal function getPageBackgroundColor():uint {
			return _bgColor;
		}
		
		/**
		 * Get the default page folding effects alpha value for this chapter.
		 * @return Folding effect alpha value for the chapter.
		 */
		internal function getPageFoldEffectAlpha():Number {
			return _foldFX;
		}
		
		/**
		 * Gets the slide delay for pages in this chapter.
		 * @return The default slide delay setting for pages in this chapter.
		 */
		internal function getSlideDelay():uint {
			return _slideDelay;
		}
		
	}
	
}