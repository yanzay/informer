require 'sqlite3'

db = SQLite3::Database.new 'topics.db'

db.execute "CREATE TABLE items(link TEXT, title TEXT, type TEXT, listened BOOLEAN);"
