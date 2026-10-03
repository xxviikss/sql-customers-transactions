create database final;
select * from customers;
update customers set Gender = null where Gender = '';
update customers set Age = null where Age = '';
alter table customers modify Age int null;

create table transactions
(
date_new DATE,
Id_check INT,
ID_client INT,
Count_products decimal(10,3),
Sum_payment decimal(10,2));

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions_new.csv"
into table transactions
fields terminated by ';'
lines terminated by '\n'
ignore 1 rows;
DESCRIBE transactions;
DESCRIBE customers;
#show variables like 'secure_file_priv'



