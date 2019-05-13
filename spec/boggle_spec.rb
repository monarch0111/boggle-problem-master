require 'http'
require 'json'
require 'dotenv/load'

def get(url, id)
  HTTP.get("#{url}/#{id}")
end

def put(url, id, params)
  HTTP.put("#{url}/#{id}", json: params)
end

def post(url, params)
  HTTP.post(url, json: params)
end

def parse(response)
  JSON.parse(response.body)
end

describe 'Boggle API test' do
  let(:url) { "#{ENV['SERVER_URL']}/games" }

  def assert_error(response, status)
    expect(response.code).to eq status
    json = parse(response)
    expect(json).to have_key('message')
  end

  def assert_not_success(response)
    expect(response.code).not_to eq 200
    json = parse(response)
    expect(json).to have_key('message')
  end

  it 'creates game with random board' do
    duration = 100
    response = post(url, { random: true, duration: duration })
    expect(response.code).to eq 201

    json = parse(response)
    expect(json).to have_key('id')
    expect(json).to have_key('token')
    expect(json).to have_key('board')
    expect(json['duration']).to eq duration
  end

  it 'creates game with specified board' do
    duration = 100
    board = "A, C, E, D, L, *, G, *, E, *, H, T, G, A, F, K"
    response = post(url, { random: false, duration: duration, board: board })
    expect(response.code).to eq 201

    json = parse(response)
    expect(json).to have_key('id')
    expect(json).to have_key('token')
    expect(json['board']).to eq board
    expect(json['duration']).to eq duration
  end

  it 'creates game with test board' do
    duration = 1000
    response = post(url, { random: false, duration: duration })
    expect(response.code).to eq 201

    json = parse(response)
    expect(json).to have_key('id')
    expect(json).to have_key('token')
    expect(json['board']).to eq('T, A, P, *, E, A, K, S, O, B, R, S, S, *, X, D')
    expect(json['duration']).to eq duration
  end

  it 'creates game with invalid input' do
    duration = 1000
    response = post(url, { duration: duration })
    assert_error(response, 400)
  end

  it 'plays game with correct word' do
    response = post(url, { random: false, duration: 1000 })
    game = parse(response)

    response = put(url, game['id'], { token: game['token'], word: 'tap' })
    expect(response.code).to eq 200

    json = parse(response)
    expect(json['id']).to eq game['id']
    expect(json['token']).to eq game['token']
    expect(json['board']).to eq game['board']
    expect(json['points']).to eq 3
    expect(json).to have_key('time_left')
  end

  it 'plays game with wrong word' do
    response = post(url, { random: false, duration: 1000 })
    game = parse(response)

    response = put(url, game['id'], { token: game['token'], word: 'thisiswrong' })
    assert_not_success(response)
  end

  it 'plays outdated game' do
    duration = 10
    response = post(url, { random: false, duration: duration })
    game = parse(response)

    sleep(duration + 1)

    response = put(url, game['id'], { token: game['token'], word: 'tap' })
    assert_not_success(response)
  end

  it 'shows game info' do
    response = post(url, { random: false, duration: 1000 })
    game = parse(response)

    response = get(url, game['id'])
    expect(response.code).to eq 200

    json = parse(response)
    expect(json['id']).to eq game['id']
    expect(json['token']).to eq game['token']
    expect(json['board']).to eq game['board']
    expect(json['points']).to eq 0
    expect(json).to have_key('time_left')
  end

  it 'displays error when game is not found' do
    response = post(url, { random: false, duration: 1000 })
    game = parse(response)

    response = get(url, -1)
    assert_error(response, 404)
  end
end
