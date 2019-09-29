require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'
require './image_uploader.rb'

enable :sessions


helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end


get '/' do
  @posts = Post.all.order("created_at desc")
  erb :index
end

get '/signup' do
  erb :sign_up
end

post '/signup' do
    @user = User.create(name:params[:name],
    password:params[:password],
  password_confirmation:params[:password_confirmation],
  img: "")

if params[:img]
    image_upload(params[:img])
  end

  if @user.persisted?
    session[:user] = @user.id
  end

  redirect '/'
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end

get '/search' do
  keyword = params[:keyword]
  uri = URI("https://itunes.apple.com/search")
  uri.query = URI.encode_www_form({ term: keyword, country: "US", media: "music", limit: 10})
  res = Net::HTTP.get_response(uri)
  returned_json = JSON.parse(res.body)
  @musics = returned_json["results"]

  erb :search
end

post '/signin' do
user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

post '/new' do
  Post.create(image: params[:image],artist: params[:artist],album: params[:album],sampleurl: params[:sampleurl],comment: params[:comment],user_id: current_user.id,user_name: current_user.name)
redirect '/home'
end

get '/home' do
   if current_user.nil?
    @posts = Post.none
  else
    @posts = current_user.posts
  end
  erb :home
end

post '/search' do
@musics = []
  erb :search
end

get '/delete/:id' do
  Post.find(params[:id]).delete
  redirect '/home'
end

get '/edit/:id' do
  @posts = Post.find(params[:id])
  erb :edit
end

post '/edit/:id/update' do
  post =  Post.find(params[:id])
  post.comment = params[:comment]
  post.save
  redirect '/home'
end