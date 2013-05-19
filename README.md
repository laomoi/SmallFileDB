SmallFileDB  (SFD)
===========

Small file db, only readable, supports multiple indexes. 小型只读的文件DB, 支持多个索引和联合索引。

The reasons I create SmallFileDB and why I am not using  sqlite: 为什么我要创建这个项目


1. I just want to query data like a hash map,  I don't want to use xml/json because I don't want to read all the data into memory.
2. 2x+ faster than sqlite since we cache the indexes. （benkmark on PC only)

===========
1. 我只想做简单查询, 但是我不想用XML/JSON，因为他们会一次性加载所有数据，占用太多内存
2. 因为缓存了索引，速度比sqlite快1倍以上(PC上测试)


The Key Design :
===========

1. The DB is composed of many tables, each table compose of .body and .index file.  ,index file will store all the indexes for the table while .body file stores the content.
2. xls2sfd  will parse xls files into sfd
3. Use libraries of lua/as3 to read the sfd, since the db is simple enough , you don't need a low level of C or sth else to support reading.
4. sfd will cache table indexes, so it might take a little bit memory if the amount of the table records are huge.

How to generate data from xlsx:
===========
There is a sample xlsx : dict_test.xlsx, it defines all tables and the indexes.


cd tools

perl xls2sfd.pl 

and there will be a folder named sfd , contains sfd files.


How to use the sfd files
===========
cd tools

perl meta2Lang.pl as3 

This command will generate as3 classes in the folder "sfdvo"

perl meta2Lang.pl lua

This command will generate lua files in the folder "sfdvo"

And then copy sfd and sfdvo into your as3/lua project.

For more detail, look into the samples directory.



Code Snippet:
===========

AS3:

	var sfd:MySFD = new MySFD();
	sfd.fileUtils.addSearchPath(File.applicationDirectory.resolvePath('sfd'));
	
	//search the item where id=12011
	var item:DictItemRecord = sfd.getDictItem().getOneById(12011);
	
	//search the items where type=1 and can_bub=1
	var ar:Array = sfd.getDictItem().getListByTypeCanBuy(1, 1);
	
	//search the items where type >= 2 and type<=3 and can_buy=1  
	//note: there should be index of (type + can_buy)
	ar = sfd.getDictItem().query("type >= 2 and type<=3 and can_buy=1");
	
	//search the items where id >= 12071 and id<=12101 
	//note: there should be index of (id)
	ar = sfd.getDictItem().query("id >= 12071 and id<=12101");


Lua:

    local mysfd = require("sfdvo.MySFD").new() -- sfdvo.MySFD#sfdvo.MySFD

    local record1 = mysfd:getDictItem():getOneById(12011)

    local ar = mysfd:getDictItem():getListByTypeCanBuy(1, 1)

   	local ar2 = mysfd:getDictItem():query("type >= 2 and type<=3 and can_buy=1");
 

 

