class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todo.sqlite")
        @db.results_as_hash = true

        return @db
    end

    get '/' do
        @todo = db.execute('SELECT * FROM todo')
        p @todo
        erb(:"index")
    end 

end
