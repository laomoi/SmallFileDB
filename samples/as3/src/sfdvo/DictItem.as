package sfdvo
{
    import com.swfdiy.sfd.SFTable;
	import com.swfdiy.sfd.SFD;

	public class DictItem extends SFTable
	{
		public function DictItem(sfd:SFD, tableName:String, clRecord:Class)
		{
			super(sfd, tableName, clRecord);
		}
		
		public function getOneById(id:int):DictItemRecord {
			return this.getOneByIndex(0, [id]) as DictItemRecord;
		}

		public function getListById(id:int):Array{
			return this.getListByIndex(0, [id]);
		}

		public function getOneByTypeCanBuy(type:int,canBuy:int):DictItemRecord {
			return this.getOneByIndex(1, [type,canBuy]) as DictItemRecord;
		}

		public function getListByTypeCanBuy(type:int,canBuy:int):Array{
			return this.getListByIndex(1, [type,canBuy]);
		}


		
	}
}