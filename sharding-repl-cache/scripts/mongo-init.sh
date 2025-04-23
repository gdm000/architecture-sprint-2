#!/bin/bash

###
# Инициализируем бд
###

docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
exit();
EOF

docker compose exec -T shard1_rs1 mongosh --port 27018 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1_rs1:27018" },
        { _id : 1, host : "shard1_rs2:27028" },
        { _id : 2, host : "shard1_rs3:27038" },
       // { _id : 1, host : "shard2:27019" }
      ]
    }
);
exit();
EOF

docker compose exec -T shard2_rs1 mongosh --port 27019 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
       // { _id : 0, host : "shard1:27018" },
        { _id : 3, host : "shard2_rs1:27019" },
        { _id : 4, host : "shard2_rs2:27029" },
        { _id : 5, host : "shard2_rs3:27039" },
      ]
    }
  );
exit();
EOF

## Init router and fill (other file)

