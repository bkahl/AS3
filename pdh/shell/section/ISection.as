﻿package pdh.shell.section{			public interface ISection	{		function restart(_config:String = null, _subpage:String = null):void;		function setSize(_w:Number, _h:Number):void;		function startup(_config:String = null, _subpage:String = null):void;		function shutdown():void;		function standby():void;	}	}