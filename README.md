SmallFileDB
===========

Small file db, only readable, supports multiple indexes.

The reason I create SmallFileDB and dont' want to use sqlite:

1. I don't need to write data into db.
2. I don't need to join table.
3. I don't want to update the whole db file if only one table changed.
4. I need a cross-platform, not os depended file db.
5. Simple enough, easy to modify the source code to fit your need.



The Key Design :

1. The DB is composed of many tables, each table has a tblxxxx.body, tblxxxx.index.  As the name,  index file will store all the indexes for the table. body file is the table content.
2. I will make many tools to generate table files, might  be a tool named xls2sfb, it will parse xls files.
3. I will create libraries of lua/as3/perl to read the small file db, since the db is simple enough , you don't need a low level of C or sth else to support reading.
4. Before reading table body, it will read the table index file and cache it, so it might take a little bit memorty if the amount of the table records are huge. Suppose we have 1000 records, only 1 primary key index,  so the index file might be 1000*8 bytes, in memory it will be read into a hash map.


