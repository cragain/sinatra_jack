require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  erb :set_name
end

post '/s/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/s/game'
end

get '/s/game' do
  session[:deck] = [['J', '10'], ['Q', '10']]
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  
  erb :game
end

get '/test' do
   
  erb :test_template
end


