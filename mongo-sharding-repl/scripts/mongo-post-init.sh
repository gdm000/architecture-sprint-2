#!/bin/bash

###
# Инициализируем бд
###

docker compose exec -T mongos_router mongosh  --port 27020 <<EOF
sh.addShard( "shard1/shard1_rs1:27018");
sh.addShard( "shard1/shard1_rs2:27028");
sh.addShard( "shard1/shard1_rs3:27038");
sh.addShard( "shard2/shard2_rs1:27019");
sh.addShard( "shard2/shard2_rs2:27029");
sh.addShard( "shard2/shard2_rs3:27039");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
exit();
EOF

docker compose exec -T mongos_router mongosh  --port 27020 <<EOF
use somedb

for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})

db.helloDoc.countDocuments()
exit();
EOF


###
# Выводим данные каждого из шардов
###

docker compose exec -T shard1_rs1 mongosh  --port 27018 <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF

docker compose exec -T shard2_rs1 mongosh  --port 27019 <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF

###
# Выводим данные реплик каждого из шардов
###
docker compose exec -T shard1_rs1 mongosh  --port 27018 <<EOF
rs.status()
exit();
EOF

docker compose exec -T shard2_rs1 mongosh  --port 27019 <<EOF
rs.status()
exit();
EOF

docker compose exec -T mongos_router mongosh  --port 27020 <<EOF
db.adminCommand({ listShards: 1 })
EOF
