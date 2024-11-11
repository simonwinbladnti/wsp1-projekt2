require 'date'

class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todo.sqlite")
        @db.results_as_hash = true

        return @db
    end

    get '/' do
        redirect('/todo')
    end

    get '/todo' do
        @todos = db.execute('SELECT * FROM todo')
        erb(:"index")
    end 

    get '/todo/create' do 
        erb(:"create")
    end

    post '/todo' do

        name = params[:todo_label]
        description = params[:todo_description]
        expiredate = params[:todo_expire_date].delete('-').to_i

        today = Date.today
        todaydate = today.strftime("%Y%m%d").to_i
        # SQL Insert
        db.execute("INSERT INTO todo (id, label, description, date_created, date_expire) VALUES(?,?,?,?,?)", [1, name, description, todaydate, expiredate ])
        
        redirect('/todo')
    end

end
