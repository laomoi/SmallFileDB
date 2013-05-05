SmallFileDB  (SFD)
===========

Small file db, only readable, supports multiple indexes. 小型只读的文件DB, 支持多个索引和联合索引。

The reasons I create SmallFileDB and why I am not using  sqlite: 为什么我要创建这个项目

1. I don't need to write data into db.
2. I don't need to join outer tables.
3. I don't want to update the whole db file if only one table changed.
4. I just want to query data like a hash map,  I don't want to use xml/json because I don't want to read all the data into memory.
5. I need a cross-platform, not os depended file db.
6. Simple enough, easy to modify the source code to fit your need.
7. 2x+ faster than sqlite since we cache the indexes. （benkmark on PC only)

1. 我不需要写数据
2. 我不需要联合外表查询
3. 我不想只是修改了某个表就要替换整个DB文件
4. 我只想做简单查询, 但是我不想用XML/JSON，因为他们会一次性加载所有数据，占用太多内存
5. 我需要一个跨平台的，但是不受操作系统限制的文件数据库
6. 足够简单，代码容易修改
7. 因为缓存了索引，速度比sqlite快1倍以上(PC上测试)


The Key Design :
===========

1. The DB is composed of many tables, each table has a tblxxxx.body, tblxxxx.index.  As the name,  index file will store all the indexes for the table. body file is the table content.
2. I will make many tools to generate table files, might  be a tool named xls2sfb, it will parse xls files.
3. I will create libraries of lua/as3/perl to read the small file db, since the db is simple enough , you don't need a low level of C or sth else to support reading.
4. Before reading table body, it will read the table index file and cache it, so it might take a little bit memorty if the amount of the table records are huge. Suppose we have 1000 records, only 1 primary key index,  so the index file might be 1000*8 bytes, in memory it will be read into a hash map.

Usage:
===========
Look at the samples directory  , right now there is a as3 sample shows how to read the db files.

1. Use tools/xls2sfd.pl to convert dict_test.xlsx to sfd/ which contains db files.
2. Use tools/meta2as3.pl to create as3 library(sfdvo/) to use the sfd  created just now.
3. Create a AS3 project, (just look into the samples\as3).

Code Snippet:
===========

AS3:

  		var sfd:MySFD = new MySFD();
		sfd.fileUtils.addSearchPath(File.applicationDirectory.resolvePath('sfd'));
		
		//search the item where id=12071
		var item:DictItemRecord = sfd.getDictItem().getOneById(12071);
		
		//search the items where type=1 and can_bub=1
		var ar:Array = sfd.getDictItem().getListByTypeCanBuy(1, 1);






