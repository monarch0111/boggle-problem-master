# require "securerandom"
# require_relative "./dictionary.rb"

# class BoggleBoard
#   @@sequence = 0
#   @@games = {}

#   ALLOWED_BOARD_CHARS = Array("A".."Z") << "*"

#   DEFAULT_BOARD = ["T", "A", "P", "*", "E", "A", "K", "S", "O", "B", "R", "S", "S", "*", "X", "D"]

#   ERROR_MESSAGES = {
#     :not_valid => "Not a valid game.",
#     :expired => "Oops! You are out of time. Game has expired.",
#     :auth_failed => "Not Authorized",
#     :not_initialized => "Invalid Game"
#   }

#   VALIDATIONS = ["expiry", "token"]

#   ROWS = 4
#   COLS = 4

#   attr_reader :errors

#   def initialize(id: , token: )
#     @id = id.to_i
#     @auth_token = token
#     @errors = []
#     @game = @@games[@id]
#     VALIDATIONS.each do |action|
#       response = send("validate_#{action}".to_sym)
#       if response[:error]
#         @errors << response[:message]
#         return
#       end
#     end
#   end

#   def play(word: )
#     raise StandardError.new(ERROR_MESSAGES[:not_initialized]) if @errors.size > 0
#     @word = word.upcase
#     score = 0
#     unless @game[:found_words].include? @word
#       score = evaluate_score
#       @game[:points] += score if score > 0
#     end
#     time_left = (@game[:duration] - (Time.now.to_f - @game[:created_at])).to_i
#     {
#       scored: score > 0,
#       body: {
#         id: @game[:id],
#         token: @game[:token],
#         duration: @game[:duration],
#         board: @game[:board],
#         time_left: time_left > 0 ? time_left : 0,
#         points: @game[:points]
#       }
#     }
#   end

#   def self.create(duration: , random: , board: nil)
#     raise ArgumentError.new("Parameter missing") if random.nil?
#     board = board.to_s.split(",").map(&:strip)
#     if board.size != 16 && !random
#       board = DEFAULT_BOARD
#     end
#     raise TypeError.new("Duration must be greater than 0") unless duration.to_i > 0
#     @@sequence += 1
#     board = (random ? get_random_board : board)
#     @@games[@@sequence] = {
#       id: @@sequence,
#       token: SecureRandom.hex,
#       created_at: Time.now.to_f,
#       duration: duration.to_i,
#       board: board.join(", "),
#       board_matrix: parse_board(board),
#       points: 0,
#       found_words: []
#     }
#     {
#       id: @@games[@@sequence][:id],
#       token: @@games[@@sequence][:token],
#       duration: @@games[@@sequence][:duration],
#       board: @@games[@@sequence][:board]
#     }
#   end

#   def self.get(id: )
#     game = @@games[id.to_i]
#     raise StandardError.new(ERROR_MESSAGES[:not_valid]) if game.nil?
#     time_left = (game[:duration] - (Time.now.to_f - game[:created_at])).to_i
#     {
#       id: game[:id],
#       token: game[:token],
#       board: game[:board],
#       duration: game[:duration],
#       time_left: time_left > 0 ? time_left: 0,
#       points: game[:points]
#     }
#   end

#   private

#   def evaluate_score
#     @visited = Array.new(ROWS) { Array.new(COLS, false)}
#     @found = false
    
#     Array(0..ROWS-1).each do |i|
#       Array(0..COLS-1).each do |j|
#         search(i,j, "")
#       end
#     end

#     if @found
#       @game[:found_words] << @word
#       score = @word.size
#       ["@found", "@visited", "@word"].each do |var|
#         remove_instance_variable(var.to_sym)
#       end
#       score
#     else
#       0
#     end
#   end

#   def search(i, j, sub_string)
#     return if @found
#     return if(i < 0 || i >= ROWS || j < 0 || j >= COLS)
#     return if @visited[i][j]

#     sub_string += @game[:board_matrix][i][j]

#     return unless @word.start_with? sub_string

#     if @word == sub_string
#       @found = true
#       return
#     end
    
#     @visited[i][j] = true
#     search(i+1, j, sub_string)
#     search(i-1, j, sub_string)
#     search(i, j+1, sub_string)
#     search(i, j-1, sub_string)
#     search(i+1, j+1, sub_string)
#     search(i-1, j-1, sub_string)
#     search(i+1, j-1, sub_string)
#     search(i-1, j+1, sub_string)
#     @visited[i][j] = false
#   end

#   def validate_token
#     unless @game[:token] == @auth_token
#       return {
#         error: true,
#         message: ERROR_MESSAGES[:auth_failed]
#       }
#     end
#     return { error: false }
#   end

#   def validate_expiry
#     if @game.nil?
#       return {
#         error: true,
#         message: (@id == 0 || @id > @@sequence) ? ERROR_MESSAGES[:not_valid] : ERROR_MESSAGES[:expired]
#       }
#     else
#       if Time.now.to_f > @game[:duration] + @game[:created_at]
#         return {
#           error: true,
#           message: ERROR_MESSAGES[:expired]
#         }
#       end
#     end
#     return { error: false }
#   end

#   class << self
#     def get_random_board
#       Array.new(16) { ALLOWED_BOARD_CHARS.sample }
#     end

#     def parse_board(board)
#       matrix = []
#       board.each_slice(ROWS) do |row|
#         matrix << row
#       end
#       matrix
#     end
#   end
# end