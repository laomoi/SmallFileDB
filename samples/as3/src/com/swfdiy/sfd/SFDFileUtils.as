package com.swfdiy.sfd
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class SFDFileUtils
	{
		public function SFDFileUtils()
		{
			_paths.push(File.applicationDirectory);
		}
		
		protected var _paths:Array = [];
		
		public function clearAllSearchPath():void {
			_paths = [];
		}
		
		public function addSearchPath(path:File):void {
			_paths.push(path);
		}
		
		public function getFile(path:String):File {
			var i:int;
			for (i=0;i<_paths.length;i++){
				var dir:File = _paths[i];
				var f:File =dir.resolvePath(path);
				if (f.exists){
					return f;
				}
			}
			return null;
		}
		
		public function getFileString(file:File):String {
			var myFileStream:FileStream = new FileStream();
			var str:String = "";
			try {
				myFileStream.open(file, FileMode.READ);
				str = myFileStream.readUTFBytes(myFileStream.bytesAvailable);
				myFileStream.close();
			} catch (e:*) {
				return "";
			}
			
			return str;
		}
	}
}