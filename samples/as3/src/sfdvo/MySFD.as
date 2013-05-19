package sfdvo
{
	import com.swfdiy.sfd.SFD;


	public class MySFD extends SFD
	{
		public function MySFD()
		{
			super();	

	       this.addTable("dict_item", DictItem, DictItemRecord);	
				
		}
		public function getDictItem():DictItem {
			return this.getTable("dict_item") as DictItem;
		}


	}
}