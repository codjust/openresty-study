#openresty-study

##postgres 使用遇到的错误

```shell
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

```shell
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

(3)openresty 使用postgres一般采用的是upstream的形式，在nginx.conf加配置：
```nginx
location /postgres {
            internal;
            default_type text/html;
            set_by_lua $query_sql '
                if ngx.var.arg_sql then
                    return ngx.unescape_uri(ngx.var.arg_sql)
                end               
                local ngx_share     = ngx.shared.ngx_cache_sql
                return ngx_share:get(ngx.var.arg_id)
                ';
            postgres_pass   database;
            rds_json          on;
            rds_json_buffer_size 16k;
            postgres_query  $query_sql;
            postgres_connect_timeout 1s;
            postgres_result_timeout 2s;
        }
       upstream database {
        postgres_server  127.0.0.1:5360  dbname=skylar
         user=postgres password=postgres;        
        postgres_keepalive max=80 mode=single overflow=reject;
    }
```
简单介绍下:
```
internal 这个指令指定所在的 location 只允许使用于处理内部请求，否则返回 404 。
set_by_lua 这一段内嵌的 Lua 代码用于计算出 $query_sql 变量的值，即后续通过指令postgres_query 发送给 PostgreSQL 处理的 SQL 语句。这里使用了GET请求的 query 参数作为 SQL 语句输入。
postgres_pass 这个指令可以指定一组提供后台服务的 PostgreSQL 数据库的 upstream
块。
rds_json 这个指令是 ngx_rds_json 提供的，用于指定 ngx_rds_json 的 output 过滤器的
开关状态，其模块作用就是一个用于把 rds 格式数据转换成 json 格式的 output filter。这个指令在这里出现意思是让 ngx_rds_json 模块帮助 ngx_postgres 模块把模块输出数据转换成 json 格式的数据。
rds_json_buffer_size 这个指令指定 ngx_rds_json用于每个连接的数据转换的内存大小.
默认是 4/8k,适当加大此参数，有利于减少 CPU 消耗。
postgres_query 指定 SQL 查询语句，查询语句将会直接发送给 PostgreSQL 数据库。
postgres_connect_timeout 设置连接超时时间。
postgres_result_timeout 设置结果返回超时时间。
```

(这里自己遇到了一个坑，要注意postgres的默认端口，在/var/lib/pgsql/9.5/data/postgresql.conf里面修改)

(4)ndk.set_var.set_quote_pgsql_str(md5_sha1)
```
ndk.set_var.set_quote_pgsql_str(md5_sha1)的作用是用来转义成适合pg存储格式的字符串
一般用在拼接sql字符串时使用

```
例如：
```lua
local sql = [[SELECT size FROM file where md5_sha1 =]]..ndk.set_var.set_quote_pgsql_str(md5_sha1)
```

###源码安装tmux遇到的一些问题，记录下：
（1）clone 源代码仓库：
```
$ git clone https://github.com/tmux/tmux.git
```
(2) 编译之前先安装libevent，去官网下载tar包：
[http://libevent.org](http://libevent.org)

选择需要下载的版本复制链接地址，使用wget下载到本地（图形化的也可以直接下载），如（选择合适的版本，一般选stable即可）：
```
    wget https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz
```

```
    tar -xfz  libevent-2.0.22-stable.tar.gz
    cd  libevent-2.0.22-stable/
    $ ./configure && make
    $ sudo make install
```

(3) 编译tmux：
```
    cd tmux/
    sh autogen.sh
   ./configure && make
```
安装编译过程可能会提示一些错误：<br>
1）aclocal command not found
原因：自动编译工具未安装，安装上即可：
```
centOS： yum install automake
```
2) configure: error: "curses or ncurses not found"
```
ubuntu：apt-get install libncurses5-dev
centos: yum install ncurses-devel
```

(4) 编译成功之后会在tmux下生成一个可执行程序：tmux
```
    ./tmux
```
执行的时候可能会出现找不到库的情况：
```shell
./tmux: error while loading shared libraries: libevent-2.0.so.5: cannot open shared object file: No such file or directory
```
把安装好的libevent库的路径使用软链接到对应的目录：
```
    64位：
        ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
    32位：
        ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
```

（5）设置环境变量
    现在使用tmux必须在编译好的目录下执行才可以，我们设置个环境变量即可：


    ln -s /home/hcw/Package/tmux/tmux /usr/bin/

    /home/hcw/Package/tmux/ 为你编译好的路径，因为/usr/bin/已经添加到系统环境变量，所以不需要再设置，如此即可使用tmux


（6）下面是我常用的tmux配置：
```
    wget https://github.com/huchangwei/dotfiles/raw/master/.tmux.conf  -P ~
```

其中需要用到插件管理，需要先安装插件管理器：
[https://github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)
```
    $ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
在.tmux.conf添加：（如果你是使用我的配置，下面可以省略）
```# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'git@github.com/user/plugin'
# set -g @plugin 'git@bitbucket.com/user/plugin'
```
```
# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
Reload TMUX environment so TPM is sourced:

# type this in terminal
$ tmux source ~/.tmux.conf
```