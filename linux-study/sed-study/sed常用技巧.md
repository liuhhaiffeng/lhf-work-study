## sed 就地替换

如文件 start  , 内容如下:

./ux_ctl -D db2 -o "-c uxdb_rac=on -c instance_id=1 -p 5432" start

需要将里面的 db2 替换为  racdata, 命令如下:

sed -i  's/db2/racdata/g' start

注: -i  表示就地替换  s:表示替换    /g:表示全部替换