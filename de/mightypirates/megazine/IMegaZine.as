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
	
	import flash.display.Stage;
	import flash.events.*;
	
	/**
	 * Interface for the MegaZine class, to be used in (external) elements. The reason the
	 * actual class is not used for external elements is to make the files smaller. They do
	 * not need to instantiate a MegaZine class, so they only need to know what methods they
	 * can call.
	 * 
	 * @author fnuecke
	 */
	public interface IMegaZine extends IEventDispatcher {
		
		/**
		 * Begin loading the megazine. Only has an effect while the megazine is in the PREINIT
		 * state. Starts loading the xml file with the megazine configuration and parses it plus
		 * generates all pages defined. Then loads the gui and sounds.
		 * After that the state is changed to READY. At the same time the actual content for the
		 * pages is loaded.
		 * If not specified otherwise in the constructor, this method is automatically called as
		 * soon as the megazine object is added to the stage.
		 * @param e make method able to be called on stage added events.
		 */
		function load(e:Event = null):void;
		
		/**
		 * The mute state for all elements that support it.
		 */
		function get muted():Boolean;
		
		/**
		 * Sets mute state for all elements that support it by firing a MegaZineEvent.MUTE event.
		 */
		function set muted(mute:Boolean):void;
		
		/**
		 * Get the number of pages in the book.
		 * @return The number of pages in the book.
		 */
		function get pageCount():uint;
		
		/**
		 * Get the default height for pages
		 * @return The default height for pages
		 */
		function get pageHeight():uint;
		
		/**
		 * Get the default width for pages
		 * @return The defaut width for pages
		 */
		function get pageWidth():uint;
		
		/**
		 * Get the current setting for reflection useage
		 * @return The current setting for reflection useage
		 */
		function get reflection():Boolean;
		
		/**
		 * Set the reflection useage
		 * @param enabled Enable the reflection or disable it.
		 */
		function set reflection(enabled:Boolean):void;
		
		/**
		 * Get the state of shadow useage for pages
		 * @return The state of shadow useage for pages
		 */
		function get shadows():Boolean;
		
		/**
		 * Set the state of shadow useage for pages
		 * @param enabled The new state of shadow useage for pages
		 */
		function set shadows(enabled:Boolean):void;
		
		/**
		 * Get the stage the megazine object resides on. Used by elements for setup when they
		 * themselves have not yet been added to the stage.
		 * @return The current stage the megazine is on.
		 */
		function get stage():Stage;
		
		/**
		 * Get the current state of this instance
		 * @return The current state of this instance
		 */
		function get state():String;
		
		/**
		 * Converts relative paths to absolute paths, using the location of the swf
		 * holding the megazine as the base location all paths are relative to.
		 * If the url starts with one of the allowed protocol types assume the url
		 * is already absolute and return it as it was, else add the absolute path
		 * component and return it.
		 * @param url The original path/url.
		 * @param protocols Array of allowed protocols that will be recognized. Per default
		 * the following protocols are recognized: http, https, file. Protocols must be defined
		 * with the completely, i.e. up to the point where the actual address starts.
		 * E.g. http is defined as http://
		 * @return The absolute path to the location specified in the given url.
		 */
		function getAbsPath(url:String, protocols:Array = null):String;
		
		/**
		 * Lists some basic information about all pages in the book.
		 * @return A string with information on the pages, separated by newlines.
		 */
		function getPageInfos():String;
		
		/**
		 * Gets the thumbnails for the left and right page for the given page.
		 * @param page The page number for which to get the left and right page.
		 * @return An array with the left page at 0 and the right at 1.
		 */
		function getThumbnailsFor(page:int):Array;
		
		/**
		 * Go to the page with the specified anchor as specified in the xml. Chapter anchors are
		 * handled via this method as well, because their anchors are just mapped to their first
		 * page.
		 * If there is no such anchor it is checked whether it is a predefined anchor. Predefined
		 * anchors are: first, last, next, prev.
		 * If it is no predefined anchor it is checked whether a number was passed, and ich yes
		 * it is interpreted as a page number.
		 * If that fails too, nothing will happen.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param id The anchor id, predefined anchorname or page number.
		 * @param instant No animation, but instantly going to the page.
		 */
		function gotoAnchor(id:String, instant:Boolean = false):void;
		
		/**
		 * Go to the page with the specified number. Numeration begins with zero.
		 * If the number does not exist the method call is ignored.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param page The number of the page to go to.
		 * @param instant No animation, but instantly going to the page.
		 */
		function gotoPage(page:uint, instant:Boolean = false):void;
		
		/**
		 * Turn to the first page of the book.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param instant No animation, but instantly going to the page.
		 */
		function firstPage(instant:Boolean = false):void;
		
		/**
		 * Turn to the last page of the book.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param instant No animation, but instantly going to the page.
		 */
		function lastPage(instant:Boolean = false):void;
		
		/**
		 * Turn to the next page in the book. If there is no next page nothing happens.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param instant No animation, but instantly going to the page.
		 */
		function nextPage(instant:Boolean = false):void;
		
		/**
		 * Turn to the previous page in the book. If there is no previous page nothing happens.
		 * If there is currently a page turn animation in progress this method does nothing.
		 * @param instant No animation, but instantly going to the page.
		 */
		function prevPage(instant:Boolean = false):void;
		
		/**
		 * Open the zoom mode for the image with the given path. The image is then loaded by
		 * the zoom container and displayed in full resolution. Pages and navigation / gui is
		 * hidden while the zoom is open.
		 * Alternatively a gallery name can be passed. In that case it is also necessary to
		 * pass a proper page number (of a page with images that are contained in that gallery)
		 * and the number of the image on that page.
		 * If set up accordingly this opens fullscreen mode. This only works if the call was
		 * initially triggered by a user action, such as a mouse click or key press.
		 * @param galleryOrPath The url to the image to load into the zoom frame, or the name
		 * of a gallery.
		 * @param page Only needed when a gallery name was passed. The number of the page the
		 * image object referencing to the gallery image resides in.
		 * @param number Only needed when a gallery name was passed. The number of the image
		 * in it's containing page (only images in the same gallery count).
		 */
		function openZoom(galleryOrPath:String, page:int = -1, number:uint = 0):void;
		
		/**
		 * Start the slideshow mode. If the current page has a delay of more than one second the
		 * first page turn is immediate (otherwise the user might get the impression nothing
		 * happened). Every next page turn will take place based on the delay stored for the
		 * current page.
		 * When the end of the book is reached the slideshow is automatically stopped.
		 * If slideshow is already active this method does nothing.
		 * Fires a MegaZineEvent.SLIDE_START event for this megazine object.
		 */
		function slideStart():void;
		
		/**
		 * Stop slideshow. If the slideshow is already stopped this method does nothing.
		 * Fires a MegaZineEvent.SLIDE_STOP event for this megazine object.
		 */
		function slideStop():void;
		
	}
	
}