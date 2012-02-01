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

package zoomify.toolbar
{
	import fl.controls.Slider;
	
	/*
	 * Slider subclassed to increase track over 4 pixels (size hardcoded in component, 
	 * styles and other means  therefore ineffective).  SliderThumb skins modified  to 
	 * include 15 pixel transparent rect in background  to serve as taller hit area.  ConfigUI() 
	 * overwritten to modify track height.
	 */
	
	public class HighSlider extends Slider
	{
		public function HighSlider()
		{
		}
		
		override protected function configUI():void {
			super.configUI();
			track.setSize(80, 15);
		}
	}
}
