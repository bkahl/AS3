/*
VERSION: 2.34
DATE: 9/17/2008
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenMax.com 
DESCRIPTION:
	TweenMax builds on top of the TweenLite core class and its big brother, TweenFilterLite, to round out the tweening family with popular 
	(though not essential) features like bezier tweening, pause/resume capabilities, easier sequencing, hex color tweening, and more. 
	TweenMax uses the same easy-to-learn syntax as its siblings. In fact, since it extends them, TweenMax can do anything TweenLite 
	and/or TweenFilterLite can do, plus more. So why build 3 classes instead of one? Good question. The goal was to maximize efficiency 
	and minimize file size. Frankly, TweenLite is probably all most developers will need for 90% of their projects, and it only takes 
	up 3k. It's extremely efficient and compact considering its features. But if you need to tween filters or rich imaging effects 
	like saturation, contrast, hue, colorization, etc., step up to TweenFilterLite at 6k (total). Still need more? No problem - use 
	TweenMax to add extra features jam-packed into 11k (total). See the feature comparison chart at www.TweenMax.com for more info. 
	TweenMax introduces an innovative feature called "bezierThrough" that allows you to define points through which you want the 
	bezier curve to travel (instead of normal control points that simply attract the curve). Or use regular bezier curves - whichever 
	you prefer.
	
	To see a feature comparison chart, go to http://www.tweenmax.com
		

ARGUMENTS:
	1) $target : Object - Target object whose properties we're tweening
	2) $duration : Number - Duration (in seconds) of the tween
	3) $vars : Object - An object containing the end values of all the properties you'd like to have tweened (or if you're using the 
	          		    TweenMax.from() method, these variables would define the BEGINNING values). For example:
						  alpha: The alpha (opacity level) that the target object should finish at (or begin at if you're 
								  using TweenMax.from()). For example, if the target_obj.alpha is 1 when this script is 
								  called, and you specify this argument to be 0.5, it'll transition from 1 to 0.5.
						  x: To change a MovieClip's x position, just set this to the value you'd like the MovieClip to 
							  end up at (or begin at if you're using TweenMax.from()). 
		  
		  SPECIAL PROPERTIES:
			  delay : Number - Amount of delay before the tween should begin (in seconds).
			  ease : Function - You can specify a function to use for the easing with this variable. For example, 
								fl.motion.easing.Elastic.easeOut. The Default is Regular.easeOut.
			  easeParams : Array - An array of extra parameters to feed the easing equation. This can be useful when you 
								   use an equation like Elastic and want to control extra parameters like the amplitude and period.
								   Most easing equations, however, don't require extra parameters so you won't need to pass in any easeParams.
			  autoAlpha : Number - Use it instead of the alpha property to gain the additional feature of toggling 
								   the visible property to false when alpha reaches 0. It will also toggle visible 
								   to true before the tween starts if the value of autoAlpha is greater than zero.
			  visible : Boolean - To set a DisplayObject's "visible" property at the end of the tween, use this special property.
			  volume : Number - Tweens the volume of an object with a soundTransform property (MovieClip/SoundChannel/NetStream, etc.)
			  tint : Number - To change a DisplayObject's tint/color, set this to the hex value of the tint you'd like
							  to end up at(or begin at if you're using TweenMax.from()). An example hex value would be 0xFF0000.
			  removeTint : Boolean - If you'd like to remove the tint that's applied to a DisplayObject, pass true for this special property.
			  frame : Number - Use this to tween a MovieClip to a particular frame.
			  bezier : Array - Bezier tweening allows you to tween in a non-linear way. For example, you may want to tween
							   a MovieClip's position from the origin (0,0) 500 pixels to the right (500,0) but curve downwards
							   through the middle of the tween. Simply pass as many objects in the bezier array as you'd like, 
							   one for each "control point" (see documentation on Flash's curveTo() drawing method for more
							   about how control points work). In this example, let's say the control point would be at x/y coordinates
							   250,50. Just make sure your my_mc is at coordinates 0,0 and then do: 
							   TweenMax.to(my_mc, 3, {_x:500, _y:0, bezier:[{_x:250, _y:50}]});
			  bezierThrough : Array - Identical to bezier except that instead of passing bezier control point values, you
									  pass points through which the bezier values should move. This can be more intuitive
									  than using control points.
			  orientToBezier : Array (or Boolean) - A common effect that designers/developers want is for a MovieClip/Sprite to 
			  						orient itself in the direction of a Bezier path (alter its rotation). orientToBezier
									makes it easy. In order to alter a rotation property accurately, TweenMax needs 4 pieces
									of information: 
										1) Position property 1 (typically "x")
										2) Position property 2 (typically "y")
										3) Rotational property (typically "rotation")
										4) Number of degrees to add (optional - makes it easy to orient your MovieClip properly)
									The orientToBezier property should be an Array containing one Array for each set of these values. 
									For maximum flexibility, you can pass in any number of arrays inside the container array, one 
									for each rotational property. This can be convenient when working in 3D because you can rotate
									on multiple axis. If you're doing a standard 2D x/y tween on a bezier, you can simply pass 
									in a boolean value of true and TweenMax will use a typical setup, [["x", "y", "rotation", 0]]. 
									Hint: Don't forget the container Array (notice the double outer brackets)
			  hexColors : Object - Although hex colors are technically numbers, if you try to tween them conventionally,
						 you'll notice that they don't tween smoothly. To tween them properly, the red, green, and 
						 blue components must be extracted and tweened independently. TweenMax makes it easy. To tween
						 a property of your object that's a hex color to another hex color, use this special hexColors 
						 property of TweenMax. It must be an OBJECT with properties named the same as your object's 
						 hex color properties. For example, if your my_obj object has a "myHexColor" property that you'd like
						 to tween to red (0xFF0000) over the course of 2 seconds, do: 
						 TweenMax.to(my_obj, 2, {hexColors:{myHexColor:0xFF0000}});
						 You can pass in any number of hexColor properties.
			  onStart : Function - If you'd like to call a function as soon as the tween begins, pass in a reference to it here.
								   This is useful for when there's a delay. 
			  onStartParams : Array - An array of parameters to pass the onStart function. (this is optional)
			  onStartListener : Function - A function to which the TweenMax instance should dispatch a TweenEvent when it begins.
			  							   This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.START, myFunction);
			  onUpdate : Function - If you'd like to call a function every time the property values are updated (on every frame during
									the time the tween is active), pass a reference to it here.
			  onUpdateParams : Array - An array of parameters to pass the onUpdate function (this is optional)
			  onUpdateListener : Function - A function to which the TweenMax instance should dispatch a TweenEvent every time it updates values.
			  							   This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.UPDATE, myFunction);
			  onComplete : Function - If you'd like to call a function when the tween has finished, use this. 
			  onCompleteParams : Array - An array of parameters to pass the onComplete function (this is optional)
			  onCompleteListener : Function - A function to which the TweenMax instance should dispatch a TweenEvent when it completes.
			  							   	  This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.COMPLETE, myFunction);
			  yoyo : Boolean - To make the tween continuously loop backwards and forwards like a yoyo, set this to true.
			  loop : Boolean - To make the tween continuously loop itself, set this to true.
			  persist : Boolean - if true, the TweenLite instance will NOT automatically be removed by the garbage collector when it is complete.
					  			  However, it is still eligible to be overwritten by new tweens even if persist is true. By default, it is false.
			  renderOnStart : Boolean - If you're using TweenFilterLite.from() with a delay and want to prevent the tween from rendering until it
										actually begins, set this to true. By default, it's false which causes TweenMax.from() to render
										its values immediately, even before the delay has expired.
			  timeScale : Number - Multiplier that controls the speed of the tween (perceived duration) where 1 = normal speed, 0.5 = half speed, 2 = double speed, etc. 
			  					   NOTE: There is also a static TweenMax.globalTimeScale property that affects ALL TweenMax and TweenFilterLite tweens (not TweenLite though)
			  overwrite : int - Controls how other tweens of the same object are handled when this tween is created. Here are the options:
			  					- 0 (NONE): No tweens are overwritten. This is the fastest mode, but you need to be careful not to create any 
			  								tweens with overlapping properties, otherwise they'll conflict with each other. 
											
								- 1 (ALL): (this is the default unless OverwriteManager.init() has been called) All tweens of the same object 
										   are completely overwritten immediately when the tween is created. 
										   		TweenLite.to(mc, 1, {x:100, y:200});
												TweenLite.to(mc, 1, {x:300, delay:2, overwrite:1}); //immediately overwrites the previous tween
												
								- 2 (AUTO): (used by default if OverwriteManager.init() has been called) Searches for and overwrites only 
											individual overlapping properties in tweens that are active when the tween begins. 
												TweenLite.to(mc, 1, {x:100, y:200});
												TweenLite.to(mc, 1, {x:300, overwrite:2}); //only overwrites the "x" property in the previous tween
												
								- 3 (CONCURRENT): Overwrites all tweens of the same object that are active when the tween begins.
												TweenLite.to(mc, 1, {x:100, y:200});
												TweenLite.to(mc, 1, {x:300, delay:2, overwrite:3}); //does NOT overwrite the previous tween because the first tween will have finished by the time this one begins.
			  
			  blurFilter : Object - To apply a BlurFilter, pass an object with one or more of the following properties:
			  						blurX, blurY, quality
			  glowFilter : Object - To apply a GlowFilter, pass an object with one or more of the following properties:
			  						alpha, blurX, blurY, color, strength, quality, inner, knockout
			  colorMatrixFilter : Object - To apply a ColorMatrixFilter, pass an object with one or more of the following properties:
										   colorize, amount, contrast, brightness, saturation, hue, threshold, relative, matrix
			  dropShadowFilter : Object - To apply a ColorMatrixFilter, pass an object with one or more of the following properties:
										  alpha, angle, blurX, blurY, color, distance, strength, quality
			  bevelFilter : Object - To apply a BevelFilter, pass an object with one or more of the following properties:
									 angle, blurX, blurY, distance, highlightAlpha, highlightColor, shadowAlpha, shadowColor, strength, quality
					  
	
KEY PROPERTIES:
	- progress : Number (0 - 1 where 0 = tween hasn't progressed, 0.5 = tween is halfway done, and 1 = tween is finished)
	- timeScale : Number (Multiplier that controls the speed of the tween where 1 = normal speed, 0.5 = half speed, 2 = double speed, etc. )
	- paused : Boolean
	- reversed : Boolean
	
KEY METHODS:
	- TweenMax.to(target:Object, duration:Number, vars:Object):TweenMax
	- TweenMax.from(target:Object, duration:Number, vars:Object):TweenMax
	- TweenMax.allTo(targets:Array, duration:Number, vars:Object):Array
	- TweenMax.allFrom(targets:Array, duration:Number, vars:Object):Array
	- TweenMax.sequence(target:Object, tweens:Array):Array
	- TweenMax.multiSequence(tweens:Array):Array
	- TweenMax.getTweensOf(target:Object):Array
	- TweenMax.isTweening(target:Object):Boolean
	- TweenMax.getAllTweens():Array
	- TweenMax.killAllTweens(complete:Boolean):void
	- TweenMax.killAllDelayedCalls(complete:Boolean):void
	- TweenMax.pauseAll(tweens:Boolean, delayedCalls:Boolean):void
	- TweenMax.resumeAll(tweens:Boolean, delayedCalls:Boolean):void
	- TweenMax.delayedCall(delay:Number, function:Function, params:Array, persist:Boolean):TweenMax
	- TweenMax.setGlobalTimeScale(scale:Number):void
	- addEventListener(type:String, listener:Function, useCapture:Boolean, priority:int, useWeakReference:Boolean):void
	- removeEventListener(type:String, listener:Function):void
	- pause():void
	- resume():void
	- restart(includeDelay:Boolean):void
	- reverse(adjustStart:Boolean):void
	- setDestination(property:String, value:*, adjustStartValues:Boolean):void
	- invalidate(adjustStartValues:Boolean):void
	- killProperties(names:Array):void
	
	
EXAMPLES: 
	To set up a sequence where we fade a MovieClip to 50% opacity over the course of 2 seconds, and then slide it down
	to y coordinate 300 over the course of 1 second:
	
		import gs.TweenMax;
		TweenMax.sequence(clip_mc, [{time:2, alpha:0.5}, {time:1, y:300}]);
	
	To tween the clip_mc MovieClip over 5 seconds, changing the alpha to 0.5, the x to 120 using the Back.easeOut
	easing function, delay starting the whole tween by 2 seconds, and then call	a function named "onFinishTween" when 
	it has completed and pass in a few parameters to that function (a value of 5 and a reference to the clip_mc), 
	you'd do so like:
		
		import gs.TweenMax;
		import gs.easing.*;
		TweenMax.to(clip_mc, 5, {alpha:0.5, x:120, ease:Back.easeOut, delay:2, onComplete:onFinishTween, onCompleteParams:[5, clip_mc]});
		function onFinishTween(argument1:Number, argument2:MovieClip):void {
			trace("The tween has finished! argument1 = " + argument1 + ", and argument2 = " + argument2);
		}
	
	If you have a MovieClip on the stage that is already in it's end position and you just want to animate it into 
	place over 5 seconds (drop it into place by changing its y property to 100 pixels higher on the screen and 
	dropping it from there), you could:
		
		import gs.TweenMax;
		import gs.easing.*;
		TweenMax.from(clip_mc, 5, {y:"-100", ease:Elastic.easeOut});
		
	To set up an onUpdate listener (not callback) that traces the "progress" property of a tween, and another listener
	that gets called when the tween completes, you could do:
	
		import gs.TweenMax;
		import gs.events.TweenEvent;
		
		TweenMax.to(clip_mc, 2, {x:200, onUpdateListener:reportProgress, onCompleteListener:tweenFinished});
		function reportProgress($e:TweenEvent):void {
			trace("tween progress: " + $e.target.progress);
		}
		function tweenFinished($e:TweenEvent):void {
			trace("tween finished!");
		}
	

NOTES:
	- Passing values as Strings will make the tween relative to the current value. For example, if you do
	  TweenMax.to(mc, 2, {x:"-20"}); it'll move the mc.x to the left 20 pixels which is the same as doing
	  TweenMax.to(mc, 2, {x:mc.x - 20}); You could also cast it like: TweenMax.to(mc, 2, {x:String(myVariable)});
	- If you prefer, instead of using the onCompleteListener, onStartListener, and onUpdateListener special properties, 
	  you can set up listeners the typical way, like: 
	  var myTween:TweenMax = TweenMax.to(my_mc, 2, {x:200});
	  myTween.addEventListener(TweenEvent.COMPLETE, myFunction);
	- To tween an Array, just pass in an Array as a property named endArray like:
	  var myArray:Array = [1,2,3,4];
	  TweenMax.to(myArray, 1.5, {endArray:[10,20,30,40]});
	- You can kill all tweens of a particular object anytime with the TweenMax.killTweensOf(myObject); function. 
	  If you want to have the tweens forced to completion, pass true as the second parameter, like TweenMax.killTweensOf(myObject, true);
	- You can kill all delayedCalls to a particular function using TweenMax.killDelayedCallsTo(myFunction);
	  This can be helpful if you want to preempt a call.
	- Use the TweenMax.from() method to animate things into place. For example, if you have things set up on 
	  the stage in the spot where they should end up, and you just want to animate them into place, you can 
	  pass in the beginning x and/or y and/or alpha (or whatever properties you want).
	  
	  
CHANGE LOG:
	2.34:
		- Fixed problem with COMPLETE event listeners not firing when killTweensOf() was called with the forceComplete parameter set to true
	2.32:
		- Fixed bug with invalidating() a tween with event listeners and adding an UPDATE listener after a tween is instantiated.
	2.31:
		- invalidate() reparses onCompleteListener, onUpdateListener, and onStartListener special properties now.
		- If a tween completed without persist:true and the globalTimeScale was updated between that time and the time restart(), reverse(), or resume() was called, it could have an incorrect timeScale. That's fixed now.
	2.3:
		- Added setGlobalTimeScale() function to control the speed of all TweenFilterLite and TweenMax instances
		- Added static "globalTimeScale" property to TweenMax and TweenFilterLite classes. You can even tween it like TweenLite.to(TweenMax, 1, {globalTimeScale:0.5});
		- Changed timeScale so that it also affects the delay (if any)
	2.26:
		- Made restart(), reverse(), and resume() force the tween back into the rendering queue even if persist wasn't set to true.
	2.24;
		- Added "persist" parameter to delayedCall() so that you can reuse/restart them.
		- Removed defaultEase from TweenMax because it was just a waste of Kb - use TweenLite.defaultEase to affect all default easing, even in TweenMax.
	2.22:
		- Added ability to include the delay when restart()-ing a tween.
	2.2:
		- Added "reversed" property
		- Fixed incorrect progress reporting on paused tweens, and potential problem with reverse()-ing paused tweens.
	2.19:
		- Fixed bug on pause/resume functionality
	2.17:
		- Changed behavior of reverse() so that it automatically calls resume().
	2.15:
		- Fixed bug in overwrite management
		- Fixed bug with tweens that have a zero-length duration
	2.12:
		- Fixed bug in timeScale
	2.1:
		- Added timeScale special property
	2.06:
		- Added the ability to overwrite only individual overlapping properties with the new OverwriteManager class
		- Added setDestination() method
		- Added killVars() method
		- Added killProperties() method
		- Added reverse() method 
		- Added restart() method
		- Added invalidate() method that forces the vars to be re-parsed (and immediately rendered if the tween is active)
		- Fixed bug in the onCompleteListener, onUpdateListener, and onStartListener special properties.
	1.5:
		- Added loop special property
		- Added yoyo special property
	1.46:
		- Fixed pauseAll() error that occurred when TweenLite instances existed
		- Improved compatibility with TweenMaxVars utility class (for strict data typing and code hinting)
		- Speed optimizations
	1.42:
		- Added ability to tween the volume of any object that has a soundTransform property instead of just MoveiClips and SoundChannels. Now NetStream volumes can be tweened too.
	1.41:
		- Fixed delayedCall() error (removed onCompleteScope since it's not useful in AS3 anyway)
	1.4:
		- Added event dispatching (onCompleteListener, onUpdateListener, and onStartListener properties)
		- Added "persist" special property
		- Added "removeTint" special property
		- Added compatibility with TweenMaxVars utility class
	1.3:
		- Added multiSequence() function, allowing you to sequence multiple items (sequence() only allows one target)
	1.2:
		- Added "visible" special property

CODED BY: Jack Doyle, jack@greensock.com
Copyright 2008, GreenSock (This work is subject to the terms in http://www.greensock.com/terms_of_use.html.)
*/

package gs {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.*;
	
	import gs.events.TweenEvent;

	public class TweenMax extends TweenFilterLite implements IEventDispatcher {
		public static var version:Number = 2.34;
		protected static const _RAD2DEG:Number = 180 / Math.PI; //precalculate for speed
		private static var _overwriteMode:int = (OverwriteManager.enabled) ? OverwriteManager.mode : OverwriteManager.init(); //OverwriteManager is optional for TweenLite and TweenFilterLite, but it is used by default in TweenMax.
		public static var killTweensOf:Function = TweenLite.killTweensOf;
		public static var killDelayedCallsTo:Function = TweenLite.killTweensOf;
		public static var removeTween:Function = TweenLite.removeTween;
		public static var setGlobalTimeScale:Function = TweenFilterLite.setGlobalTimeScale;
		protected var _pauseTime:int;
		protected var _dispatcher:EventDispatcher;
		protected var _callbacks:Object; //stores the original onComplete, onStart, and onUpdate Functions from the this.vars Object (we replace them if/when dispatching events)
		
		public function TweenMax($target:Object, $duration:Number, $vars:Object) {
			super($target, $duration, $vars);
			_pauseTime = -1;
			if (this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null) {
				initDispatcher();
				if ($duration == 0 && this.delay == 0) {
					onUpdateDispatcher();
					onCompleteDispatcher();
				}
			}
			if (this.vars.yoyo == true || this.vars.loop == true) {
				this.vars.persist = true;
			}
			if (TweenFilterLite.version < 8.22) {
				trace("TweenMax error! Please update your TweenFilterLite class or try deleting your ASO files. TweenMax requires a more recent version. Download updates at http://www.TweenMax.com.");
			}
		}
				
		override public function initTweenVals($hrp:Boolean = false, $reservedProps:String = ""):void {
			$reservedProps += " hexColors bezier bezierThrough orientToBezier quaternions onCompleteAll onCompleteAllParams yoyo loop onCompleteListener onUpdateListener onStartListener ";
			var p:String, i:int, curProp:Object, props:Object, b:Array;
			if (!$hrp && this.delay != 0 && TweenLite.overwriteManager.enabled) {
				TweenLite.overwriteManager.manageOverwrites(this, _all[this.target]);
			}
			var bProxy:Function = bezierProxy; 
			if (this.vars.orientToBezier == true) {
				this.vars.orientToBezier = [["x", "y", "rotation", 0]];
				bProxy = bezierProxy2;
			} else if (this.vars.orientToBezier is Array) {
				bProxy = bezierProxy2;
			}
			if (this.vars.bezier != undefined && (this.vars.bezier is Array)) {
				props = {};
				b = this.vars.bezier;
				for (i = 0; i < b.length; i++) {
					for (p in b[i]) {
						if (props[p] == undefined) {
							props[p] = [this.target[p]];
						}
						if (typeof(b[i][p]) == "number") {
							props[p].push(b[i][p]);
						} else {
							props[p].push(this.target[p] + Number(b[i][p])); //relative value
						}
					}
				}
				for (p in props) {
					if (typeof(this.vars[p]) == "number") {
						props[p].push(this.vars[p]);
					} else {
						props[p].push(this.target[p] + Number(this.vars[p])); //relative value
					}
					delete this.vars[p]; //to prevent TweenLite from doing normal tweens on these Bezier values.
				}
				addSubTween("bezier", bProxy, {t:0}, {t:1}, {props:parseBeziers(props, false), target:this.target, orientToBezier:this.vars.orientToBezier});
			}
			if (this.vars.bezierThrough != undefined && (this.vars.bezierThrough is Array)) {
				props = {};
				b = this.vars.bezierThrough;
				for (i = 0; i < b.length; i++) {
					for (p in b[i]) {
						if (props[p] == undefined) {
							props[p] = [this.target[p]]; //starting point
						}
						if (typeof(b[i][p]) == "number") {
							props[p].push(b[i][p]);
						} else {
							props[p].push(this.target[p] + Number(b[i][p])); //relative value
						}
					}
				}
				for (p in props) {
					if (typeof(this.vars[p]) == "number") {
						props[p].push(this.vars[p]);
					} else {
						props[p].push(this.target[p] + Number(this.vars[p])); //relative value
					}
					delete this.vars[p]; //to prevent TweenLite from doing normal tweens on these Bezier values.
				}
				addSubTween("bezierThrough", bProxy, {t:0}, {t:1}, {props:parseBeziers(props, true), target:this.target, orientToBezier:this.vars.orientToBezier});
				
			}
			/* potential new feature - quaternion tweening
			if (this.vars.quaternions != undefined) {
				var angle:Number, q1:Object, q2:Object, x1:Number, x2:Number, y1:Number, y2:Number, z1:Number, z2:Number, w1:Number, w2:Number, theta:Number;
				for (p in this.vars.quaternions) {
					q1 = this.target[p];
					q2 = this.vars.quaternions[p];
					x1 = q1.x; x2 = q2.x;
					y1 = q1.y; y2 = q2.y;
					z1 = q1.z; z2 = q2.z;
					w1 = q1.w; w2 = q2.w;
					angle = x1 * x2 + y1 * y2 + z1 * z2 + w1 * w2;
					if (angle < 0) {
						x1 *= -1;
						y1 *= -1;
						z1 *= -1;
						w1 *= -1;
						angle *= -1;
					}
					if ((angle + 1) < 0.000001) {
						y2 = -y1;
						x2 = x1;
						w2 = -w1;
						z2 = z1;
					}
					theta = Math.acos(angle);
					addSubTween("quaternions", quaternionProxy, {t:0}, {t:1}, {target:q1, prop:p, x1:x1, x2:x2, y1:y1, y2:y2, z1:z1, z2:z2, w1:w1, w2:w2, angle:angle, theta:theta, invTheta:1 / Math.sin(theta)});
				}
			}
			*/
			if (this.vars.hexColors != undefined && typeof(this.vars.hexColors) == "object") {
				for (p in this.vars.hexColors) {
					addSubTween("hexColors", hexColorsProxy, {r:this.target[p] >> 16, g:(this.target[p] >> 8) & 0xff, b:this.target[p] & 0xff}, {r:(this.vars.hexColors[p] >> 16), g:(this.vars.hexColors[p] >> 8) & 0xff, b:(this.vars.hexColors[p] & 0xff)}, {prop:p, target:this.target});
				}
			}
			super.initTweenVals(true, $reservedProps);
		}
		
		public function pause():void {
			if (_pauseTime == -1) {
				_pauseTime = _curTime;
				this.startTime = 99999999999; //required for OverwriteManager
				_active = false;
			}
		}
		
		public function resume():void {
			if (_pauseTime != -1) {
				var d:Number = this.delay * (1000 / _timeScale); //delay in milliseconds
				var started:Boolean = (_pauseTime > this.initTime + d);
				var gap:Number = _curTime - _pauseTime;
				this.initTime += gap;
				this.startTime = this.initTime + d;
				_pauseTime = -1;
				if (!started && _curTime >= this.startTime) {
					started = this.active; //triggers onStart if necessary and initTweenVals()
				} else {
					_active = started;
				}
			}
			enable();
		}
		
		public function restart($includeDelay:Boolean=false):void {
			if ($includeDelay) {
				this.initTime = _curTime;
				this.startTime = _curTime + (this.delay * (1000 / _timeScale));
			} else {
				this.startTime = _curTime;
				this.initTime = _curTime - (this.delay * (1000 / _timeScale));
			}
			if (this.target != this.vars.onComplete) { //protects delayedCall()s from being rendered.
				render(this.startTime); 
			}
			_pauseTime = -1;
			enable();
		}
		
		public function reverse($adjustDuration:Boolean=true):void {
			this.vars.ease = (this.vars.ease == _originalEase) ? reverseEase : _originalEase;
			var p:Number = this.progress;
			if (_pauseTime != -1) {
				if (p < 1) {
					resume();
				} else {
					_pauseTime = -1;
					_active = true;
				}
			}
			if ($adjustDuration && p > 0) {
				this.startTime = _curTime - ((1 - p) * this.duration * 1000 / _timeScale);
				this.initTime = this.startTime - (this.delay * (1000 / _timeScale));
			}
			enable();
		}
		
		public function reverseEase($t:Number, $b:Number, $c:Number, $d:Number):Number {
			return _originalEase($d - $t, $b, $c, $d);
		}
		
		protected function enable():void { //just makes sure it's in the render queue. For example, if persist wasn't set to true and the tween already completed, it gets taken out of the rendering queue, but if the user kept track of it in a variable and wants to restart() or reverse() or resume(), we need a way to make sure it's back in the queue.
			if (_all[this.target] == undefined) {
				_all[this.target] = new Dictionary(true);
			}
			if (_all[this.target][this] != this) {
				_timeScale = _uncombinedTimeScale * _globalTimeScale;
				_all[this.target][this] = this;
			}
		}
		
		public function invalidate($adjustStartValues:Boolean=true):void { //forces the vars to be re-parsed and immediately re-rendered
			if (_initted) {
				var p:Number = this.progress;
				if (!$adjustStartValues && p != 0) {
					this.progress = 0;
				}
				this.tweens = [];
				_subTweens = [];
				initTweenVals();
				_timeScale = (this.vars.timeScale || 1) * _globalTimeScale;
				if (this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null) {
					if (_dispatcher != null) {
						this.vars.onStart = _callbacks.onStart;
						this.vars.onUpdate = _callbacks.onUpdate;
						this.vars.onComplete = _callbacks.onComplete;
						_dispatcher = null;
					}
					initDispatcher();
				}
				if (p != 0) {
					if ($adjustStartValues) {
						adjustStartValues();
					} else {
						this.progress = p;
					}
				}
			}
		}
		
		public function setDestination($property:String, $value:*, $adjustStartValues:Boolean=true):void {
			var p:Number = this.progress;
			if (this.vars[$property] != undefined && _initted) {
				if (!$adjustStartValues && p != 0) {
					for (var i:int = this.tweens.length - 1; i > -1; i--) {
						if (this.tweens[i].name == $property) {
							this.tweens[i].o[this.tweens[i].p] = this.tweens[i].s; //return it to its start value
						}
					}
				}
				var v:Object = {};
				v[$property] = 1;
				killVars(v);
			}
			this.vars[$property] = $value;
			if (_initted) {
				var varsOld:Object = this.vars;
				var tweensOld:Array = this.tweens;
				var subTweensOld:Array = _subTweens;
				this.vars = {};
				this.tweens = [];
				_subTweens = [];
				this.vars[$property] = $value;
				initTweenVals();
				if ($adjustStartValues && p != 0) {
					this.vars.ease = varsOld.ease;
					adjustStartValues();
				}
				this.vars = varsOld;
				this.tweens = tweensOld.concat(this.tweens);
				_subTweens = subTweensOld.concat(_subTweens);
			}
		}
		
		protected function adjustStartValues():void { //forces the current
			var p:Number = this.progress;
			if (p != 0) {
				var factor:Number = 1 / (1 - this.vars.ease(p * this.duration, 0, 1, this.duration));
				var endValue:Number, tp:Object, i:int;
				for (i = this.tweens.length - 1; i > -1; i--) {
					tp = this.tweens[i];
					endValue = tp.s + tp.c;
					tp.c = (endValue - tp.o[tp.p]) * factor;
					tp.s = endValue - tp.c;
				}
			}
		}
		
		public function killProperties($names:Array):void {
			var v:Object = {}, i:int;
			for (i = $names.length - 1; i > -1; i--) {
				if (this.vars[$names[i]] != null) {
					v[$names[i]] = 1;
				}
			}
			killVars(v);
		}
		
		override public function complete($skipRender:Boolean = false):void {
			if (this.vars.yoyo == true || this.vars.loop == true) {
				if (this.vars.yoyo == true) { //extra validation in case killTweensOf() was called in an onComplete.
					reverse(false);
				}
				this.startTime = _curTime;
				this.initTime = this.startTime - (this.delay * (1000 / _timeScale));
			} else if (this.vars.persist == true) {
				pause();
			}
			super.complete($skipRender);
		}
		
		
//---- EVENT DISPATCHING ----------------------------------------------------------------------------------------------------------
		
		protected function initDispatcher():void {
			if (_dispatcher == null) {
				_dispatcher = new EventDispatcher(this);
				_callbacks = {onStart:this.vars.onStart, onUpdate:this.vars.onUpdate, onComplete:this.vars.onComplete}; //store the originals
				var v:Object = {};
				for (var p:String in this.vars) {
					v[p] = this.vars[p]; //Just in case the same vars Object is reused for multiple tweens, we need to copy all the properties and create a duplicate so that we don't interfere with other tweens.
				}
				this.vars = v;
				this.vars.onStart = onStartDispatcher;
				this.vars.onComplete = onCompleteDispatcher;
				
				if (this.vars.onStartListener is Function) {
					_dispatcher.addEventListener(TweenEvent.START, this.vars.onStartListener, false, 0, true);
				}
				if (this.vars.onUpdateListener is Function) {
					_dispatcher.addEventListener(TweenEvent.UPDATE, this.vars.onUpdateListener, false, 0, true);
					this.vars.onUpdate = onUpdateDispatcher; //To improve performance, we only want to add UPDATE dispatching if absolutely necessary.
					_hasUpdate = true;
				}
				if (this.vars.onCompleteListener is Function) {
					_dispatcher.addEventListener(TweenEvent.COMPLETE, this.vars.onCompleteListener, false, 0, true);
				}
			}
		}
		
		protected function onStartDispatcher(... $args):void {
			if (_callbacks.onStart != null) {
				_callbacks.onStart.apply(null, this.vars.onStartParams);
			}
			_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
		}
		
		protected function onUpdateDispatcher(... $args):void {
			if (_callbacks.onUpdate != null) {
				_callbacks.onUpdate.apply(null, this.vars.onUpdateParams);
			}
			_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
		}
		
		protected function onCompleteDispatcher(... $args):void {
			if (_callbacks.onComplete != null) {
				_callbacks.onComplete.apply(null, this.vars.onCompleteParams);
			}
			_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
		}
		
		public function addEventListener($type:String, $listener:Function, $useCapture:Boolean = false, $priority:int = 0, $useWeakReference:Boolean = false):void {
			if (_dispatcher == null) {
				initDispatcher();
			}
			if ($type == TweenEvent.UPDATE && this.vars.onUpdate != onUpdateDispatcher) { //To improve performance, we only want to add UPDATE dispatching if absolutely necessary.
				this.vars.onUpdate = onUpdateDispatcher;
				_hasUpdate = true;
			}
			_dispatcher.addEventListener($type, $listener, $useCapture, $priority, $useWeakReference);
		}
		
		public function removeEventListener($type:String, $listener:Function, $useCapture:Boolean = false):void {
			if (_dispatcher != null) {
				_dispatcher.removeEventListener($type, $listener, $useCapture);
			}
		}
		
		public function hasEventListener($type:String):Boolean {
			if (_dispatcher == null) {
				return false;
			} else {
				return _dispatcher.hasEventListener($type);
			}
		}
		
		public function willTrigger($type:String):Boolean {
			if (_dispatcher == null) {
				return false;
			} else {
				return _dispatcher.willTrigger($type);
			}
		}
		
		public function dispatchEvent($e:Event):Boolean {
			if (_dispatcher == null) {
				return false;
			} else {
				return _dispatcher.dispatchEvent($e);
			}
		}
		
		
//---- STATIC FUNCTIONS -----------------------------------------------------------------------------------------------------------
		
		public static function to($target:Object, $duration:Number, $vars:Object):TweenMax {
			return new TweenMax($target, $duration, $vars);
		}
		
		public static function from($target:Object, $duration:Number, $vars:Object):TweenMax {
			$vars.runBackwards = true;
			return new TweenMax($target, $duration, $vars);
		}
	
		public static function allTo($targets:Array, $duration:Number, $vars:Object):Array { //vars takes the same special parameters as to() and from() calls, and ALSO "delayIncrement", "onCompleteAll", "onCompleteAllParams", and "onCompleteAllScope"
			if ($targets.length == 0) {
				return [];
			}
			var i:int, v:Object, p:String, dl:Number, lastVars:Object;
			var a:Array = [];
			var dli:Number = $vars.delayIncrement || 0;
			delete $vars.delayIncrement;
			if ($vars.onCompleteAll == undefined) {
				lastVars = $vars;
			} else {
				lastVars = {}; //need to create a new object so that we can have a different onComplete and onCompleteParams properties!
				for (p in $vars) {
					lastVars[p] = $vars[p]; //Create a new object and copy the properties, otherwise easeParams will throw errors.
				}
				lastVars.onCompleteParams = [[$vars.onComplete, $vars.onCompleteAll], [$vars.onCompleteParams, $vars.onCompleteAllParams]];
				lastVars.onComplete = TweenMax.callbackProxy;
				delete $vars.onCompleteAll;
			}
			delete $vars.onCompleteAllParams;
			if (dli == 0) {
				for (i = 0; i < $targets.length - 1; i++) {
					v = {};
					for (p in $vars) {
						v[p] = $vars[p]; //Create a new object and copy the properties so that we can have a different delay value.
					}
					a[a.length] = new TweenMax($targets[i], $duration, v);
				}
			} else {
				dl = $vars.delay || 0;
				for (i = 0; i < $targets.length - 1; i++) {
					v = {};
					for (p in $vars) {
						v[p] = $vars[p];
					}
					v.delay = dl + (i * dli);
					a[a.length] = new TweenMax($targets[i], $duration, v);
				}
				lastVars.delay = dl + (($targets.length - 1) * dli);
			}		
			a[a.length] = new TweenMax($targets[$targets.length - 1], $duration, lastVars); //add this to the end so the onCompleteAll fires last. NOTE: In AS2, we have to flip this when all the durations are the same (add it FIRST, not last, so that it executes last)
			
			if ($vars.onCompleteAllListener is Function) {
				a[a.length - 1].addEventListener(TweenEvent.COMPLETE, $vars.onCompleteAllListener);
			}
			return a;
		}
		
		public static function allFrom($targets:Array, $duration:Number, $vars:Object):Array {
			$vars.runBackwards = true;
			return allTo($targets, $duration, $vars);
		}
		
		public static function callbackProxy($functions:Array, $params:Array = null):void {
			for (var i:uint = 0; i < $functions.length; i++) {
				if ($functions[i] != undefined) {
					$functions[i].apply(null, $params[i]);
				}
			}
		}
		
		public static function sequence($target:Object, $tweens:Array):Array { //Note: make sure each tween object has a "time" parameter (duration in seconds).
			for (var i:uint = 0; i < $tweens.length; i++) {
				$tweens[i].target = $target;
			}
			return multiSequence($tweens);
		}
		
		public static function multiSequence($tweens:Array):Array { //Note: make sure each tween object has a "target" parameter and a "time" parameter ("time" is in seconds)
			var dict:Dictionary = new Dictionary();
			var a:Array = [];
			var overwriteMode:int = TweenLite.overwriteManager.mode;
			var totalDelay:Number = 0;
			var tw:Object, tgt:Object, dl:Number, t:Number, i:uint, o:Object, p:String;
			for (i = 0; i < $tweens.length; i++) {
				tw = $tweens[i];
				t = tw.time || 0;
				o = {};
				for (p in tw) {
					o[p] = tw[p]; //copy the object so that we can edit it without interfering with the original object which may be used again if the developer runs the same sequence multiple times.
				}
				delete o.time;
				dl = o.delay || 0;
				o.delay = totalDelay + dl;
				tgt = o.target;
				delete o.target;
				
				if (overwriteMode == 1) {
					if (dict[tgt] == undefined) { //By default, we should set overwrite to true for the FIRST tween of each Object. Of course subsequent tweens shouldn't ovewrite each other.
						dict[tgt] = o;
					} else {
						o.overwrite = 2;
					}
				}
				
				a[a.length] = new TweenMax(tgt, t, o);
				totalDelay += t + dl;
			}
			return a;
		}
		
		public static function delayedCall($delay:Number, $onComplete:Function, $onCompleteParams:Array=null, $persist:Boolean=false):TweenMax {
			return new TweenMax($onComplete, 0, {delay:$delay, onComplete:$onComplete, onCompleteParams:$onCompleteParams, persist:$persist, overwrite:0});
		}
		
		public static function parseBeziers($props:Object, $through:Boolean=false):Object { //$props object should contain a property for each one you'd like bezier paths for. Each property should contain a single array with the numeric point values (i.e. props.x = [12,50,80] and props.y = [50,97,158]). It'll return a new object with an array of values for each property, containing a "s" (start), "cp" (control point), and "e" (end) property. (i.e. returnObject.x = [{s:12, cp:32, e:50}, {s:50, cp:65, e:80}])
			var i:int, a:Array, b:Object, p:String;
			var all:Object = {};
			if ($through) {
				for (p in $props) {
					a = $props[p];
					all[p] = b = [];
					if (a.length > 2) {
						b[b.length] = {s:a[0], cp:a[1] - ((a[2] - a[0]) / 4), e:a[1]};
						for (i = 1; i < a.length - 1; i++) {
							b[b.length] = {s:a[i], cp:a[i] + (a[i] - b[i - 1].cp), e:a[i + 1]};
						}
					} else {
						b[b.length] = {s:a[0], cp:(a[0] + a[1]) / 2, e:a[1]};
					}
				}
			} else {
				for (p in $props) {
					a = $props[p];
					all[p] = b = [];
					if (a.length > 3) {
						b[b.length] = {s:a[0], cp:a[1], e:(a[1] + a[2]) / 2};
						for (i = 2; i < a.length - 2; i++) {
							b.push({s:b[i - 2].e, cp:a[i], e:(a[i] + a[i + 1]) / 2});
						}
						b[b.length] = {s:b[b.length - 1].e, cp:a[a.length - 2], e:a[a.length - 1]};
					} else if (a.length == 3) {
						b[b.length] = {s:a[0], cp:a[1], e:a[2]};
					} else if (a.length == 2) {
						b[b.length] = {s:a[0], cp:(a[0] + a[1]) / 2, e:a[1]};
					}
				}
			}
			return all;
		}
		
		public static function getTweensOf($target:Object):Array {
			var t:Dictionary = _all[$target];
			var a:Array = [];
			if(t != null) {
				for (var p:Object in t) {
					if (t[p].tweens != undefined) {
						a[a.length] = t[p];
					}
				}
			}
			return a;
		}
		
		public static function isTweening($target:Object):Boolean {
			var a:Array = getTweensOf($target);
			for (var i:int = a.length - 1; i > -1; i--) {
				if (a[i].active) {
					return true;
				}
			}
			return false;
		}
		
		public static function getAllTweens():Array {
			var a:Dictionary = _all; //speeds things up slightly
			var all:Array = [], p:Object, tw:Object;
			for each (p in a) {
				for (tw in p) {
					if (p[tw] != undefined) {
						all[all.length] = p[tw];
					}
				}
			}
			return all;
		}
		
		public static function killAllTweens($complete:Boolean = false):void {
			killAll($complete, true, false);
		}
		
		public static function killAllDelayedCalls($complete:Boolean = false):void {
			killAll($complete, false, true);
		}
		
		public static function killAll($complete:Boolean = false, $tweens:Boolean = true, $delayedCalls:Boolean = true):void {
			var a:Array = getAllTweens();
			var isDC:Boolean; //is delayedCall
			for (var i:int = a.length - 1; i > -1; i--) {
				isDC = (a[i].target == a[i].vars.onComplete);
				if (isDC == $delayedCalls || isDC != $tweens) {
					if ($complete) {
						a[i].complete();
					} else {
						TweenLite.removeTween(a[i]);
					}
				}
			}
		}
		
		public static function pauseAll($tweens:Boolean = true, $delayedCalls:Boolean = false):void {
			changePause(true, $tweens, $delayedCalls);
		}
		
		public static function resumeAll($tweens:Boolean = true, $delayedCalls:Boolean = false):void {
			changePause(false, $tweens, $delayedCalls);
		}
		
		public static function changePause($pause:Boolean, $tweens:Boolean = true, $delayedCalls:Boolean = false):void {
			var a:Array = getAllTweens();
			var isDC:Boolean; //is delayedCall
			for (var i:int = a.length - 1; i > -1; i--) {
				isDC = (a[i].target == a[i].vars.onComplete);
				if (a[i] is TweenMax && (isDC == $delayedCalls || isDC != $tweens)) {
					a[i].paused = $pause;
				}
			}
		}
	
	

//---- PROXY FUNCTIONS ------------------------------------------------------------------------------------------------------------
	
		public static function hexColorsProxy($o:Object):void {
			$o.info.target[$o.info.prop] = uint($o.target.r << 16 | $o.target.g << 8 | $o.target.b);
		}
		public static function bezierProxy($o:Object):void {
			var factor:Number = $o.target.t, props:Object = $o.info.props, tg:Object = $o.info.target, i:int, p:String, b:Object, t:Number, segments:uint;
			if (factor == 1) { //to make sure the end values are EXACTLY what they need to be.
				for (p in props) {
					i = props[p].length - 1;
					tg[p] = props[p][i].e;
				}
			} else {
				for (p in props) {
					segments = props[p].length;
					if (factor < 0) {
						i = 0;
					} else if (factor >= 1) {
						i = segments - 1;
					} else {
						i = int(segments * factor);
					}
					t = (factor - (i * (1 / segments))) * segments;
					b = props[p][i];
					tg[p] = b.s + t * (2 * (1 - t) * (b.cp - b.s) + t * (b.e - b.s));
				}
			}
		}
		
		public static function bezierProxy2($o:Object):void { //Only for orientToBezier tweens. Separated it for speed.
			bezierProxy($o);
			var future:Object = {};
			var tg:Object = $o.info.target;
			$o.info.target = future;
			$o.target.t += 0.01;
			bezierProxy($o);
			var otb:Array = $o.info.orientToBezier;
			var a:Number, dx:Number, dy:Number, cotb:Array, toAdd:Number;
			for (var i:uint = 0; i < otb.length; i++) {
				cotb = otb[i]; //current orientToBezier Array
				toAdd = cotb[3] || 0;
				dx = future[cotb[0]] - tg[cotb[0]];
				dy = future[cotb[1]] - tg[cotb[1]];
				tg[cotb[2]] = Math.atan2(dy, dx) * _RAD2DEG + toAdd;
			}
			$o.info.target = tg;
			$o.target.t -= 0.01;
		}
		
		/* potential new feature - slerp quaternion tweening for 3D rotation
		public static function quaternionProxy($o:Object):void {
			var info:Object = $o.info, t:Number = $o.target.t, tg:* = info.target, scale:Number, invScale:Number;
			if ((info.angle + 1) > 0.000001) {
				 if ((1 - info.angle) >= 0.000001) {
					scale = Math.sin(info.theta * (1 - t)) * info.invTheta;
					invScale = Math.sin(info.theta * t) * info.invTheta;
				 } else {
					scale = 1 - t;
					invScale = t;
				 }
			} else {
				scale = Math.sin(Math.PI * (0.5 - t));
				invScale = Math.sin(Math.PI * t);
			}
			tg.x = scale * info.x1 + invScale * info.x2;
			tg.y = scale * info.y1 + invScale * info.y2;
			tg.z = scale * info.z1 + invScale * info.z2;
			tg.w = scale * info.w1 + invScale * info.w2;
		}
		*/
	
//---- GETTERS / SETTERS ----------------------------------------------------------------------------------------------------------
	
		override public function get active():Boolean {
			if (_active) {
				return true;
			} else if (_pauseTime != -1) {
				return false;
			} else if (_curTime >= this.startTime) {
				_active = true;
				if (!_initted) {
					initTweenVals();
				} else if (this.vars.visible != undefined && _isDisplayObject) {
					this.target.visible = true;
				}
				if (this.vars.onStart != null) {
					this.vars.onStart.apply(null, this.vars.onStartParams);
				}
				if (this.duration == 0.001) { //In the constructor, if the duration is zero, we shift it to 0.001 because the easing functions won't work otherwise. We need to offset the this.startTime to compensate too.
					this.startTime -= 1;
				}
				return true;
			} else {
				return false;
			}
		}
	
		public function get paused():Boolean {
			return (_pauseTime != -1);
		}
		public function set paused($b:Boolean):void {
			if ($b) {
				pause();
			} else {
				resume();
			}
		}
		public function get reversed():Boolean {
			return (this.vars.ease == reverseEase);
		}
		public function set reversed($b:Boolean):void {
			if (this.reversed != $b) {
				reverse();
			}
		}
		public static function set globalTimeScale($n:Number):void {
			setGlobalTimeScale($n);
		}
		public static function get globalTimeScale():Number {
			return _globalTimeScale;
		}
		public function get progress():Number {
			var t:Number = (_pauseTime != -1) ? _pauseTime : _curTime;
			var p:Number = (((t - this.initTime) / 1000) - this.delay / _timeScale) / this.duration * _timeScale;
			if (p > 1) {
				return 1;
			} else if (p < 0) {
				return 0;
			} else {
				return p;
			}
		}
		public function set progress($n:Number):void {
			this.startTime = _curTime - ((this.duration * $n) * 1000);
			this.initTime = this.startTime - (this.delay * (1000 / _timeScale));
			var b:Boolean = this.active; //Just to trigger all the onStart stuff.
			render(_curTime);
			if (_pauseTime != -1) {
				_pauseTime = _curTime;
				this.startTime = 99999999999; //required for OverwriteManager
			}
			var v:* = this.vars.visible;
			if (this.vars.isTV == true) {
				v = this.vars.exposedProps.visible;
			}
			if (v != null && _isDisplayObject && $n < 1) {
				this.target.visible = Boolean(v);
			}
		}
		
	}
}