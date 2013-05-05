package com.swfdiy.sfd
{
	import flash.filesystem.File;

	public class SFD
	{
		public function SFD()
		{
			fileUtils = new SFDFileUtils;
		}
		
		protected var _tables:Object = {};
		protected var _tableFactory:Object = {};
		public var fileUtils:SFDFileUtils;
		
		
		protected function addTable(t:String, clTable:Class, clRecord:Class):void {
			_tableFactory[t] = [clTable, clRecord];
		}
		
		
		
		protected function getTable(t:String):SFTable {
			if (!_tables[t]){
				var cls:Array = _tableFactory[t] as Array;
				if (!cls){
					throw new Error(t + " has no creator");
					return null;
				}
				var clTable:Class = cls[0] as Class;
				var clRecord:Class = cls[1] as Class;

				_tables[t] = new clTable(this, t, clRecord);
			}
			return _tables[t];
		}
		
	}
}