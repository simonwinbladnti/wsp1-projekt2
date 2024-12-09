require 'date'
require 'bcrypt'
require 'securerandom'

class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todo.sqlite")
        @db.results_as_hash = true

        return @db
    end

    configure do
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
    end

    def logged_in?
        session[:user_id]
    end

    def admin?
        current_user && current_user['username'] == 'admin'
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
            redirect '/todos'
        else
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
        redirect('/todos')
    end

    get '/todos' do
        redirect('/login') unless logged_in?
        p(session[:user_id],session[:user_id],session[:user_id],session[:user_id],session[:user_id])
        @todos = db.execute('SELECT * FROM todo WHERE id = ?', session[:user_id])
        erb(:"todos/index")
    end 

    get '/admin' do
        redirect('/login') unless logged_in?
        redirect('/todos') unless admin? 

        @users = db.execute('SELECT * FROM users')
        erb(:"admin")
    end 

    get '/admin/users/create' do
        redirect('/login') unless logged_in?
        redirect('/todos') unless admin?

        erb(:"create_user")
    end

    post '/admin/users' do
        redirect('/login') unless logged_in?
        redirect('/todos') unless admin?

        username = params[:username]
        password = params[:password]

        password_hashed = BCrypt::Password.create(password)

        db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, password_hashed])

        redirect '/admin'
    end

    get '/todos/create' do 
        redirect('/login') unless logged_in?
        erb(:"todos/create")
    end

    post '/todos' do

        name = params[:todo_label]
        description = params[:todo_description]
        expiredate = params[:todo_expire_date].delete('-').to_i

        today = Date.today
        todaydate = today.strftime("%Y%m%d").to_i
        # SQL Insert
        db.execute("INSERT INTO todo (id, label, description, date_created, date_expire) VALUES(?,?,?,?,?)", [session[:user_id], name, description, todaydate, expiredate ])
        
        redirect('/todos')
    end

    post '/todos/:id/complete' do |id|
        current_status = db.execute('SELECT status FROM todo WHERE todo_id = ?', id).first['status']
      
        new_status = current_status == 1 ? 0 : 1
      
        db.execute('UPDATE todo SET status = ? WHERE todo_id = ?', [new_status, id])
      
        redirect '/todos'
    end

    post '/todos/:id/delete' do |id|
        @fruit = db.execute('DELETE FROM todo WHERE todo_id=?', id)
      
        redirect '/todos'
    end

    get '/todos/:id/edit' do
        @id = params[:id]  
        erb:"todos/edit"
    end

    post '/todos/:id/update' do | id |
        name = params[:todo_name]
        description = params[:todo_description]

        db.execute('UPDATE todo SET description = ?, label = ? WHERE todo_id = ?', [description, name, id])

        redirect('/todos')
    end
end
