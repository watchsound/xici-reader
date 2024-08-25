CREATE TABLE IF NOT EXISTS images (
image_id INTEGER PRIMARY KEY autoincrement,
image_uuid text default '',
container_id text default '',
content BLOB
);

CREATE TABLE IF NOT EXISTS forums (
forum_id  text default '',
forum_title text default '',
forum_category text default '',
forum_sub_category text default '',
forum_icon  BLOB,
subscribed int(1) default 0,
top_forum  int(1) default 0,
icon_local text default ''
);

CREATE TABLE IF NOT EXISTS users (
user_id text default '',
user_name text default '',
sex  int(1) default 0,
friend int(1) default 0,
fan  int(1) default 0,
user_icon BLOB
);



CREATE TABLE IF NOT EXISTS discussion (
discussion_id text default '', 
forum_id text default '',
user_id  text default '',
content text default '',
timestamp long default 0,
last_update long default 0,
total_reply INTEGER default 0,
title text default ''
);

CREATE TABLE IF NOT EXISTS discussion_reply (
discussion_reply_id INTEGER PRIMARY KEY autoincrement,
discussion_id text default '',
discussion_order_num INTEGER default 0,
user_id text default 0,
content text default '',
timestamp long default 0
);

