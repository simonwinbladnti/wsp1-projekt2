require 'sqlite3'
require 'bcrypt'


class Seeder
  
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS todo')
  end

  def self.create_tables
    db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password VARCHAR(255) NOT NULL
    )')
    db.execute('CREATE TABLE todo (
      todo_id INTEGER PRIMARY KEY AUTOINCREMENT,
      id INTEGER NOT NULL,
      label TEXT NOT NULL,
      description TEXT NOT NULL,
      date_created INTEGER NOT NULL,
      date_expire INTEGER,
      status INTEGER DEFAULT "0" NOT NULL
    )')
  end

  def self.populate_tables
    password_hashed = BCrypt::Password.create("admin")
    p "Storing hashed version of password to db. Clear text never saved. #{password_hashed}"
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["admin", password_hashed])
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/todo.sqlite')
    @db.results_as_hash = true
    @db
  end
end


Seeder.seed!