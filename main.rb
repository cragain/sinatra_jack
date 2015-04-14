require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

before do
  @show_hit_and_stay_button = true
end




get '/' do
  erb :set_name
end

post '/s/set_name' do

  session[:player_name] = params[:player_name]
  redirect '/s/game'
end

get '/s/game' do
  
  session[:turn] = session[:player_name]
  
  # Setup the Deck
  suits = ['H', 'D', 'C', 'S']
  cvalue = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(cvalue).shuffle!
  
  #Deal the cards
  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  
  if calculate_card_total(session[:player_cards]) == 21
    @success = "BLACKJACK BABY!!"
    @show_hit_and_stay_button = false
  end
  
  erb :game
end

get '/test' do
   
  erb :test_template
end

post '/quit' do
  erb :game_over
end

get '/dealer_hit' do
  session[:dealer_cards] << session[:deck].pop
  
  if calculate_card_total(session[:dealer_cards]) > 16
    @dealer_has_to_hit = false
    redirect '/winner'
  end
  redirect '/winner'
end



post '/hit_it' do
  session[:player_cards] << session[:deck].pop
  
  if calculate_card_total(session[:player_cards]) == 21
    @success = "BLACKJACK BABY!!"
    @show_hit_and_stay_button = false
  elsif calculate_card_total(session[:player_cards]) > 21
    @error = "Sorry, it seems you took one too many...BUSTED"
    @show_hit_and_stay_button = false
  end
  erb :game
end

post '/stay' do
  session[:turn] = "dealer"
  @success = "You have chosen to stay..."
  @show_hit_and_stay_button = false
  if calculate_card_total(session[:dealer_cards]) < 17
    @dealer_has_to_hit = true
  else redirect '/winner'
  end
  
  
  erb :game
end

get '/winner' do
  @show_hit_and_stay_button = false
    
    if calculate_card_total(session[:dealer_cards]) > 21
       @success = "DEALER BUSTS- YOU WIN BABY!"
       @play_again = true
     elsif calculate_card_total(session[:dealer_cards]) < 17
       @dealer_has_to_hit = true
    elsif calculate_card_total(session[:dealer_cards]) > calculate_card_total(session[:player_cards])
       @error = "OH NO, DEALER Wins..."
       @play_again = true
    elsif calculate_card_total(session[:dealer_cards]) == calculate_card_total(session[:player_cards])
       @maybe = "CRAZY- ITS A TIE!!"
       @play_again = true
    else @success = "WINNER WINNER CHICKEN DINNER, YOU WIN BABY!"
      @play_again = true
    end

  erb :game
end

helpers do
  def calculate_card_total(cvalue)
    
    arr = cvalue.map{|c| c[1]}
    
    total = 0
    arr.each do |value|
      if value == "A"
        total += 11
      elsif value == "J"
        total += 10
      elsif value == "Q"
        total += 10
      elsif value == "K"
        total += 10
      else total += value.to_i
      end
    end
    
    # Ace Conversion When Above 21
    arr.select{|c| c =="A"}.count.times do
      if total > 21
        total -= 10
      end
    end
    
    total
  end
  
  def card_image(card_array)
    suit = case card_array[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end
    
    value = card_array[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card_array[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    
    "<img src=/images/cards/#{suit}_#{value}.jpg class= 'card_image'>"
  end
  
  def dealer_bust
    
  end
  
end


