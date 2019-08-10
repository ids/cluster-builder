create database kafka;
use kafka;
create table data_kv (
  data_id INT AUTO_INCREMENT,
  data_key VARCHAR(255) NOT NULL,
  data_value TEXT,
  PRIMARY KEY (data_id)
);
insert into data_kv (data_key, data_value) values ('seed1', 'some initial data in the table');
insert into data_kv (data_key, data_value) values ('seed2', 'more initial data in the table');
commit;
