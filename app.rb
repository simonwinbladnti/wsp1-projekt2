require 'date'
require 'bcrypt'

class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todo.sqlite")
        @db.results_as_hash = true

        return @db
    end

    def logged_in?
        session[:user_id]
    end

    def current_user
    @current_user ||= db.execute("SELECT * FROM users WHERE id = ?", session[:user_id]).first if logged_in?
    end

    get '/login' do
    erb :login
    end
    
    post '/login' do
        username = params[:username]
        password = params[:password]

        user = db.execute("SELECT * FROM users WHERE username = ?", username).first

        if user && BCrypt::Password.new(user['password']) == password
            session[:user_id] = user['id']
            redirect '/todo'
        else
            print('ajwdjadjd')
            @error = "Invalid username or password"
            erb :login
        end
    end

    get '/logout' do
    session.clear
    redirect '/login'
    end

    get '/' do
    redirect('/login') unless logged_in?
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
