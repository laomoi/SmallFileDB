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

1. The DB is composed of many tables, each table has a tblxxxx.body, tblxxxx.index.  As the name,  index file will store all the indexes for the table. body file is the table content.
2. I will make many tools to generate table files, might  be a tool named xls2sfb, it will parse xls files.
3. I will create libraries of lua/as3/perl to read the small file db, since the db is simple enough , you don't need a low level of C or sth else to support reading.
4. Before reading table body, it will read the table index file and cache it, so it might take a little bit memorty if the amount of the table records are huge. Suppose we have 1000 records, only 1 primary key index,  so the index file might be 1000*8 bytes, in memory it will be read into a hash map.

How to generate data from xlsx:
===========
There is a sample xlsx : dict_test.xlsx, it defines all tables and the indexes.


cd tools

perl xls2sfd.pl 

and there will be a folder named sfd generated, contains sfd files.


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
	
	//search the item where id=12071
	var item:DictItemRecord = sfd.getDictItem().getOneById(12071);
	
	//search the items where type=1 and can_bub=1
	var ar:Array = sfd.getDictItem().getListByTypeCanBuy(1, 1);


Lua:

    local mysfd = require("sfdvo.MySFD").new() -- sfdvo.MySFD#sfdvo.MySFD

    local record1 = mysfd:getDictItem():getOneById(12011)

    local ar = mysfd:getDictItem():getListByTypeCanBuy(1, 1)

   	local ar2 = mysfd:getDictItem():query("type >= 2 and type<=3 and can_buy=1");
 

 

