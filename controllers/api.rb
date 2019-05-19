require "sinatra/base"
require "sinatra/json"
require "json"

require_relative "./concerns/response.rb"

Dir[__dir__ + '/../models/**/*.rb'].each do |filename|
  require filename
end

class API < Sinatra::Base
  include Response
  START_TIME = Time.now

  post '/games' do
    result = begin
      body_params = JSON.parse(request.body.read)
      response_body(code: 201, body: Boggle::Board.create(
        duration: body_params["duration"],
        random: body_params["random"],
        board: body_params["board"])
      )
    rescue ArgumentError, JSON::ParserError, TypeError => e
      bad_request
    end

    status result[:code]
    json result[:body]
  end  

  get '/games/:id' do |game_id|
    result = begin
      response_body(code: 200, body: Boggle::Board.get(id: game_id))
    rescue StandardError => e
      response_body(code: 404, body: {message: "Game not found"})
    end

    status result[:code]
    json result[:body]
  end

  put '/games/:id' do |game_id|
    result = begin
      @body_params = JSON.parse(request.body.read)
      game = Boggle::Game.new(id: game_id, token: @body_params["token"])
      if game.errors.empty?
        score = game.play(word: @body_params["word"])
        if score > 0
          response_body(code: 200, body: Boggle::Board.get(id: game_id))
        else
          bad_request("Oops! Wrong Word!")
        end
      else
        bad_request(game.errors.join(" ,"))
      end
    rescue JSON::ParserError, TypeError => e
      bad_request
    end
    status result[:code]
    json result[:body]
  end

  get '/health' do
    status 200
    json({
      uptime: Time.now - START_TIME,
      games_generated: Boggle::Board.sequence
    })
  end
end

API.run!