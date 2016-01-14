# CREATE KEYSPACE test_keyspace with replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }

CREATE TABLE test(
  id text,
  a text,
  b text,
  PRIMARY KEY((id), a)
  );

CREATE TABLE test2(
  id text,
  x text,
  y text,
  PRIMARY KEY((id), x)
  );

CREATE TABLE mod_test(
 row int,
 id text,
 mod_key int,
 val text,
 PRIMARY KEY ((row, mod_key), id)
 );
