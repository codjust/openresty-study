# openresty-study

#postgres 使用遇到的错误

```
使用psql -U postgres -d skylar -h 127.0.0.1 -p 5432连接数据库时，出现以下错误：

(1)
psql: 致命错误:  用户 "postgres" Ident 认证失败

解决方法：
    vim /var/lib/pgsql/data/pg_hba.conf（如果是9.5，则是/var/lib/pgsql/9.5/data
/pg_hba.conf）

打开修改：
#IPv4 lcoal connections:
host all all 127.0.0.1/32 ident

为
#IPv4 lcoal connections:
host all all 127.0.0.1/32 trust

```

```
(2)执行psql -U postgres skylar出现
psql: 致命错误:  对用户"postgres"的对等认证失败
解决方法：
vi /etc/PostgreSQL/9.4/main/pg_hba.conf

# "local" is for Unix domain socket connections only
local all all peer

将peer改成 md5
即：
local all all md5
重启PostgreSQL数据服务：（9.5版本）
systemctl restart postgresql-9.5.service

再登陆即可
```


