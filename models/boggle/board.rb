require "securerandom"
module Boggle
  class Board

    ROWS = 4
    COLS = 4

    @@sequence = 0
    @@games = {}

    ALLOWED_BOARD_CHARS = Array("A".."Z") << "*"

    DEFAULT_BOARD = ["T", "A", "P", "*", "E", "A", "K", "S", "O", "B", "R", "S", "S", "*", "X", "D"]

    def self.sequence
      @@sequence
    end

    def self.games
      @@games
    end

    def self.create(duration: , random: , board: nil)
      raise ArgumentError.new("Parameter missing") if random.nil?
      board = board.to_s.split(",").map(&:strip)
      if board.size != 16 && !random
        board = DEFAULT_BOARD
      end
      raise TypeError.new("Duration must be greater than 0") unless duration.to_i > 0
      @@sequence += 1
      board = (random ? get_random_board : board)
      @@games[@@sequence] = {
        id: @@sequence,
        token: SecureRandom.hex,
        created_at: Time.now.to_f,
        duration: duration.to_i,
        board: board.join(", "),
        board_matrix: parse_board(board),
        points: 0,
        found_words: []
      }
      {
        id: @@games[@@sequence][:id],
        token: @@games[@@sequence][:token],
        duration: @@games[@@sequence][:duration],
        board: @@games[@@sequence][:board]
      }
    end

    def self.get(id: )
      game = @@games[id.to_i]
      raise StandardError.new(ERROR_MESSAGES[:not_valid]) if game.nil?
      time_left = (game[:duration] - (Time.now.to_f - game[:created_at])).to_i
      {
        id: game[:id],
        token: game[:token],
        board: game[:board],
        duration: game[:duration],
        time_left: time_left > 0 ? time_left: 0,
        points: game[:points]
      }
    end

    private

    def self.get_random_board
      Array.new(16) { ALLOWED_BOARD_CHARS.sample }
    end

    def self.parse_board(board)
      matrix = []
      board.each_slice(ROWS) do |row|
        matrix << row
      end
      matrix
    end
    
  end
end
