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
	import de.mightypirates.utils.Helper;
	import de.mightypirates.utils.Localizer;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.text.*;
	
	/**
	 * The text element can be used to display blocks of text.
	 * 
	 * @author fnuecke
	 */
	public class Text extends AbstractElement {
		
		// ----------------------------------------------------------------------------------- //
		// Constructor
		// ----------------------------------------------------------------------------------- //
		
		/**
		 * Creates a new text element.
		 * @param mz   The MegaZine containing the page containing this element.
		 * @param lib  The library to obtain gui graphics from.
		 * @param page The page containing this element.
		 * @param even On the odd or on the even page?
		 * @param xml  The XML data for this element.
		 */
		public function Text(mz:IMegaZine, loc:Localizer, lib:ILibrary,
						     page:IPage, even:Boolean, xml:XML)
		{
			super(mz, loc, lib, page, even, xml);
		}
		
		override public function init():void {
			
			var t:TextField = new TextField();
			t.autoSize = TextFieldAutoSize.LEFT;
			t.multiline = true;
			t.selectable = false;
			t.wordWrap = true;
			t.width = _mz.pageWidth - x;
			t.height = _mz.pageHeight - y;
			
			// Text color
			t.textColor = Helper.validateInt(_xml.@color, 0, 0);
			
			// Text alignment.
			var align:String = TextFormatAlign.LEFT;
			if (_xml.@align != undefined) {
				switch(_xml.@align.toString()) {
					case "right":
						align = TextFormatAlign.RIGHT;
						break;
					case "center":
						align = TextFormatAlign.CENTER;
						break;
					case "justify":
						align = TextFormatAlign.JUSTIFY;
						break;
				}
			}
			t.defaultTextFormat = new TextFormat("Verdana, Helvetica, Arial, _sans", "12",
												 null, null, null, null, null, null, align);
			// Get custom width and height if given and smaller than the max value.
			var xmlWidth:uint = Helper.validateUInt(_xml.@width, 0);
			if (xmlWidth > 0) {
				t.width = Math.min(t.width, xmlWidth);
			}
			var xmlHeight:uint = Helper.validateUInt(_xml.@height, 0);
			if (xmlHeight > 0) {
				t.height = Math.min(t.height, xmlHeight);
			}
			
			t.htmlText = _xml.toString();
			var bd:BitmapData = new BitmapData(t.width, t.height, true, 0);
			var oldQuality:String = _mz.stage.quality;
			_mz.stage.quality = StageQuality.BEST;
			bd.draw(t);
			_mz.stage.quality = oldQuality;
			bd.lock();
			addChild(new Bitmap(bd, PixelSnapping.NEVER, true));
			
			super.init();
		}
		
	}
	
}
