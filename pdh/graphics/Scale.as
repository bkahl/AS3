﻿package pdh.graphics{		import flash.geom.Point;	import flash.display.Sprite;		public class Scale	{				  /**        * Scale around an arbitrary centre point        * @param Number local horizontal offset from 'real' registration point        * @param Number local vertical offset from 'real' registration point        * @param Number relative scaleX increase; e.g. 2 to double, 0.5 to half        * @param Number relative scaleY increase        */        public static function findNewPos(clip:Sprite, _newScale:Number):Point{/// offsetX:Number, offsetY:Number, absScaleX:Number, absScaleY:Number ):void {          		 		 var _x = clip.x		 var _y = clip.y		 var _width = clip.width		 var _height = clip.height		 		 // scaling will be done relatively          var relScaleX:Number = _newScale / clip.scaleX;           var relScaleY:Number = _newScale / clip.scaleY;           // map vector to centre point within parent scope          var AC:Point = new Point( _width/2, _height/2 );                     var AB:Point = new Point( _x, _y );           // CB = AB - AC, this vector that will scale as it runs from the centre          var CB:Point = AB.subtract( AC );           CB.x *= relScaleX;           CB.y *= relScaleY;           // recaulate AB, this will be the adjusted position for the clip          AB = AC.add( CB );    		  return new Point( AB.x,  AB.y);       }   		} // end class	}  // end package