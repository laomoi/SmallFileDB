package com.swfdiy.sfd
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class SFTable
	{
		protected var _sfd:SFD;
		protected var _name:String;
		protected var _clRecord:Class;
		protected var _indexes:Array;
		protected var _meta:Object;
		protected var _positions:Array;
		
		protected var _bodyStream:FileStream;
		public function SFTable(sfd:SFD, tableName:String, clRecord:Class)
		{
			_sfd = sfd;
			_name = tableName;
			_clRecord = clRecord;
			
			//read meta
			var metaFile:File = sfd.fileUtils.getFile(_name +  ".meta");
			if (metaFile == null){
				throw new Error(_name + " has no meta file " );
			}
			
			_meta = JSON.parse(sfd.fileUtils.getFileString(metaFile));
			if (_meta== null ) {
				throw new Error(_name + " meta file incorrect " );
			}
			
			//read in indexes? or later?
			var indexFile:File = sfd.fileUtils.getFile(_name +  ".index");
			if (indexFile == null){
				throw new Error(_name + " has no index file " );
			}
			
			_indexes = JSON.parse(sfd.fileUtils.getFileString(indexFile)) as Array;
			if (_indexes== null || _indexes.length == 0 ) {
				throw new Error(_name + " index file incorrect " );
			}	
			
			//read positions for datas
			var positionFile:File = sfd.fileUtils.getFile(_name +  ".pos");
			if (positionFile == null){
				throw new Error(_name + " has no position file " );
			}
			var myFileStream:FileStream = new FileStream();
			myFileStream.open(positionFile, FileMode.READ);
			_positions = [];
			while(myFileStream.bytesAvailable){
				var pos:int = myFileStream.readInt();
				_positions.push(pos);
			}
			myFileStream.close();
			
			
			//open body data prepare reading
			var bodyFile:File = sfd.fileUtils.getFile(_name +  ".body");
			if (bodyFile == null){
				throw new Error(_name + " has no body file " );
			}
			_bodyStream = new FileStream();
			_bodyStream.open(bodyFile, FileMode.READ);
		}
		
		protected function getDataPositionListByIndex(index:int, values:Array):Array {
			var indexData:Object = _indexes[index]; 
			if (!indexData){
				throw new Error(_name + " has no index " + index);
				return null;
			}
			
			var i:int;
			var indexListData:Object = indexData['_data'];
			var data:Object = indexListData;

			for (i=0;i<values.length;i++){
				data = data[values[i]];
				if (!data){
					return [];
				}
			}
			return data as Array;
		}
		
		protected function getDataByPosition(posIndex:int):Object {
			var pos:int = _positions[posIndex];
			
			_bodyStream.position = pos;
			
			var types:Array = _meta['types'];
			var rnames:Array = _meta['rnames'];
			var data:Object = new _clRecord();
			var i:int;
			for (i=0;i<types.length;i++){
				var rname:String = rnames[i];
				if (types[i] == "int"){ 
					data[rname] = _bodyStream.readInt();
				} else if (types[i] == "string"){
					var l:int = _bodyStream.readShort();
					data[rname] = _bodyStream.readUTFBytes(l);
				}
			}
			return data;
		} 
		
		protected function getOneByIndex(index:int, values:Array):Object{
			var list:Array = getDataPositionListByIndex(index, values);
			if (list && list.length > 0){
				return getDataByPosition(list[0]);
			} else {
				return null;
			}
		}
		
		protected function getListByIndex(index:int, values:Array):Array{
			var list:Array = getDataPositionListByIndex(index, values);
			var listData:Array = [];
			for (var i:int=0;i<list.length;i++){
				listData.push(getDataByPosition(list[i]));
			}
			return listData;
		}
		public function close():void {
			if (_bodyStream){
				_bodyStream.close();
				_bodyStream = null;
			}
			_sfd = null;
		}
		
	}
}