package
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.system.System;
	import flash.utils.getTimer;
	
	import sfdvo.DictItemRecord;
	import sfdvo.MySFD;

	
	public class TestSFD extends Sprite
	{
		public function TestSFD()
		{
			super();
			
			var sfd:MySFD = new MySFD();
			sfd.fileUtils.addSearchPath(File.applicationDirectory.resolvePath('sfd'));
			
			//search the item where id=12071
			var item:DictItemRecord = sfd.getDictItem().getOneById(12071);
			
			//search the items where type=1 and can_bub=1
			var ar:Array = sfd.getDictItem().getListByTypeCanBuy(1, 1);
	
		}
	}
}