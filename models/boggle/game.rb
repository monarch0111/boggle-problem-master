module Boggle
  class Game

    ERROR_MESSAGES = {
      :not_valid => "Not a valid game.",
      :expired => "Oops! You are out of time. Game has expired.",
      :auth_failed => "Not Authorized",
      :not_initialized => "Invalid Game"
    }

    VALIDATIONS = ["expiry", "token"]

    attr_reader :errors

    def initialize(id: , token: )
      @id = id.to_i
      @auth_token = token
      @errors = []
      @game = Board.games[@id]
      VALIDATIONS.each do |action|
        response = send("validate_#{action}".to_sym)
        if response[:error]
          @errors << response[:message]
          return
        end
      end
    end

    def play(word: )
      raise StandardError.new(ERROR_MESSAGES[:not_initialized]) if @errors.size > 0
      @word = word.upcase
      return 0 unless Dictionary.search(@word)
      score = 0
      unless @game[:found_words].include? @word
        score = evaluate_score
        @game[:points] += score if score > 0
      end
      score
    end

    private

    def evaluate_score
      @visited = Array.new(Board::ROWS) { Array.new(Board::COLS, false)}
      @found = false
      
      Array(0..Board::ROWS-1).each do |i|
        Array(0..Board::COLS-1).each do |j|
          search(i,j, "")
        end
      end

      if @found
        @game[:found_words] << @word
        @word.size
      else
        0
      end
    end

    def search(i, j, sub_string)
      return if @found
      return if(i < 0 || i >= Board::ROWS || j < 0 || j >= Board::COLS)
      return if @visited[i][j]

      sub_string += @game[:board_matrix][i][j]

      return if match_score(@word, sub_string) == 0

      if match_score(@word, sub_string) == 1
        @found = true
        return
      end
      
      @visited[i][j] = true
      search(i+1, j, sub_string)
      search(i-1, j, sub_string)
      search(i, j+1, sub_string)
      search(i, j-1, sub_string)
      search(i+1, j+1, sub_string)
      search(i-1, j-1, sub_string)
      search(i+1, j-1, sub_string)
      search(i-1, j+1, sub_string)
      @visited[i][j] = false
    end

    def match_score(string, sub_string)
      # Method uses String match function by converting wild-card string to a regex
      matched_data = string.match(sub_string.gsub("*", "\\w"))
      return 0 if matched_data.nil?
      # score is ratio of total characters matched to total characters in the string
      matched_data[0].to_s.length.to_f / string.length.to_f
    end

    def validate_token
      unless @game[:token] == @auth_token
        return {
          error: true,
          message: ERROR_MESSAGES[:auth_failed]
        }
      end
      return { error: false }
    end

    def validate_expiry
      if @game.nil?
        return {
          error: true,
          message: (@id == 0 || @id > Board.sequence) ? ERROR_MESSAGES[:not_valid] : ERROR_MESSAGES[:expired]
        }
      else
        if Time.now.to_f > @game[:duration] + @game[:created_at]
          return {
            error: true,
            message: ERROR_MESSAGES[:expired]
          }
        end
      end
      return { error: false }
    end

  end
end