require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'board.rb'
require_relative 'ai_player.rb'

enable :sessions

get '/' do
  puts "Get"
  erb :index
end

get '/new' do
  puts "New"
  session[:board] = nil
  session[:status] = nil
  session[:turn] = :white
  session[:game_over] = true
  redirect '/'
end

post '/' do
  input = params[:input]
  puts "Post: input=#{input}"
  session[:status] = nil

  if input == "restart"
    puts "Post: restart"
    redirect '/new'
  elsif session[:game_over] == true
    puts "Post: select side"
    if input == 'white' || input == 'black'
      session[:side] = (input == 'white') ? :white : :black
      session[:board] = Board.new
      session[:board].setup
      session[:turn] = :white
      session[:machine] = AI_Player.new(input == 'white' ? :black : :white, session[:board])
      session[:game_over] = false
      session[:status] = "It's #{session[:turn]}'s turn."
    end
  else
    puts "Post: regular game play"
    board = session[:board]
    side = session[:side] # the side of the human player
    turn = session[:turn] # the side that needs to move next
    start = session[:start]

    if !session[:promote].nil?
      puts "Post: promote"
      puts "promote=#{session[:promote]}, prompt=#{session[:prompt_promote]}"
      if !session[:prompt_promote] ||
         (input == "queen" || input == "rook" || input == "bishop" || input == "knight")
        new_piece = promote
        board.promote(session[:promote], new_piece)
        next_turn
        session[:promote] = nil
        session[:prompt_promote] = nil
      end
    elsif turn == side
      # Player's turn
      puts "Post: player turn"
      if start.nil? || board.get_side(input) == side
        puts "Start=" + input
        session[:start] = input
      else
        puts "End=" + input
        success, message = board.execute_move(start + input, side)
        session[:start] = nil
        session[:end] = nil
        if success
          next_turn if !promote?
        else
          session[:message] = message
        end
      end
    else
      # Machine's turn
      puts "Post: machine turn"
      machine = session[:machine]
      success, message = board.execute_move(machine.get_input, machine.side)
      next_turn if !promote?
    end

    turn = session[:turn]

    if board.in_check?(turn)
      if board.mate?(turn)
        opponent = (turn == :white) ? "Black" : "White"
        session[:status] = highlight("Checkmate!")
        session[:status] += " #{opponent} wins!"
        session[:game_over] = true
      else
        session[:status] = "It's #{turn}'s turn."
        session[:status] += highlight(" Check!")
      end
    elsif board.mate?(turn)
      session[:status] = highlight("Stalemate!")
      session[:game_over] = true
    elsif board.draw?
      session[:status] = highlight("Draw!")
      session[:game_over] = true
    else
      session[:status] = "It's #{turn}'s turn."
    end
  end

  # Initiate a GET request to display the updated state.
  redirect "/"
end

# Returns the image name of the piece to be displayed at the specified board
# coordinate.
def get_image(coordinate)
  img = nil
  if !session[:board].nil?
    name, side = session[:board].get_name_and_side(coordinate)
    if !name.nil?
      img = "<img src='pieces/#{name}_#{side}.png' />"
      if coordinate == session[:start]
        img += "<span id='selected'></span>"
      end
    end
  end
  img
end

def highlight(msg)
  "<span id=highlight>#{msg}</span>"
end

def promote?
  status = false
  # Check if a pawn needs to be promoted
  piece = session[:board].promote?
  if piece != nil
    status = true
    session[:promote] = piece
    if piece.side == session[:side]
      session[:prompt_promote] = true
    end
  end
  status
end

def promote
  piece = nil
  if session[:prompt_promote]
    puts "promote to #{params[:input]}"
    case params[:input]
    when 'queen'
      piece = Queen.new(nil, session[:side], nil)
    when 'rook'
      piece = Rook.new(nil, session[:side], nil)
    when 'bishop'
      piece = Bishop.new(nil, session[:side], nil)
    when 'knight'
      piece = Knight.new(nil, session[:side], nil)
    end
  else
    piece = session[:machine].promote(session[:promote])
  end
  piece
end

def next_turn
  session[:turn] = (session[:turn] == :white) ? :black : :white
end
