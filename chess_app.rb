require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'board.rb'
#require_relative 'ai.rb'

enable :sessions

get '/' do
  erb :index
end

post '/' do
  if params["input"] == "restart"
    session[:board] = Board.new
    session[:turn] = 'White'
    session[:game_over] = true
  elsif session[:game_over].nil? || session[:game_over] == true
    session[:board] = Board.new
    session[:board].setup
    session[:turn] = 'White'
    session[:game_over] = false
    session[:first_turn] = true

    if params["input"] == 'White' || params["input"] == 'Black'
      session[:side] = params["input"]
    else
      session[:side] = 'White'
      session[:input] = params["input"]
      #session[:board].mark(session[:input], session[:turn])
      session[:turn] = 'Black'
    end

    #session[:machine] = AI_Player.new(session[:side] == 'White' ? 'Black' : 'White')
  else
    session[:input] = params["input"]

    #if session[:turn] == session[:side]
    #  # Player's turn
    #  if session[:board].mark(session[:input], session[:turn])
    #    session[:turn] = (session[:turn] == 'White') ? 'Black' : 'White'
    #  end
    #else
    #  # Machine's turn - make it possible to sometimes beat it.
    #  if session[:first_turn] && [true, true, false].sample
    #    # Make a "bad" first move.
    #    positions = [2,4,6,8]
    #    position = positions.sample
    #    if !session[:board].get(position).nil?
    #      # If that position is already taken, try again.
    #      positions.delete(position)
    #      position = positions.sample
    #    end
    #    session[:board].mark(position, session[:turn])
    #  else
    #    session[:board].mark(session[:machine].get_next_move(session[:board]), session[:turn])
    #  end
#
    #  session[:turn] = (session[:turn] == 'White') ? 'Black' : 'White'
    #  session[:first_turn] = false
    #end
  end

  #winner = session[:board].check_winner
  #if !winner.nil?
  #  session[:status] = "<span id='bold'>#{winner} wins!</span>"
  #  session[:game_over] = true
  #elsif !session[:board].moves_left?
  #  session[:status] = "<span id='bold'>It's a draw!</span>"
  #  session[:game_over] = true
  #else
  #  session[:status] = "It's #{session[:turn]}'s turn."
  #end

  # Initiate a GET request to display the updated state.
  redirect "/"
end

# Returns the image name of the piece to be displayed at the specified board
# coordinate.
def get_image(coordinate)
  puts coordinate
end
