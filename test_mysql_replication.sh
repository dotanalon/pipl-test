#!/bin/bash

echo "Clean test table.."
docker exec -it mysql_master mysql -uroot -prootpwd -D pipl -e "DROP TABLE dummy;"

echo "Insert data to master..."
docker exec -it mysql_master mysql -uroot -prootpwd -D pipl -e "create table dummy(a varchar(255));"

for i in {1..10}; do
	docker exec -it mysql_master mysql -uroot -prootpwd -D pipl -e "insert into dummy set a=$i;"
done

echo "Validating Slave..."
docker exec -it mysql_slave mysql -uroot -prootpwd -D pipl -e "select count(*) from dummy;"

