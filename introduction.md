# Boggle Problem

## Contents
 - [Challenges & Approach](#challenges)
 - [Setup Instructions](#setup-instructions)
 - [Directory & File Structure](#directory-file-structure)
 - [API Documentation](#api-documentation)

### Challenges
 - I: To find, if the given word is a valid word?
 - II: To find, if the given word can be formed using board.
 - III: Having wild-card(`*`) possibility adds another level of complexity to Challenge II

### Approach

#### Challenge I
> Searching a word from the list of given words is a classical dicitonary problem.

Dictionary Search can be implemented in many ways

 - `Arrays with Binary Search`: Given word is in sorted manner, we can load all the words into an in-memory Array.
 	- Search Time Complexity: We can perfrom binary search in `O(log N)` where N is the length of dictionary array. But for comparision in which direction to proceed(left or right) further will have complexity of `O(L)` where L is the average length of the words. Leading to a total complexity of `O(log N) + O(L)`
 	- Memory Footprint: To keep data in-memory, it will take N * L characters space.
 - `HashMap`: All the given can be put as keys into a HashMap
 	- Search Time Complexity: HashMap provides us with an average case search operation time of `O(1)`, but if dictionary size is huge there is a possibility of hash collision which will increase the time complexity further.
 	- Memory Footprint: To keep data in-memory, it will take N * L characters space.
 - `Trie`: A trie is a tree-like data structure whose nodes store the letters of an alphabet. By structuring the nodes in a particular way, words and strings can be retrieved from the structure by traversing down a branch path of the tree.
 	- Search Time Complexity: Searching in a Trie would have O(L) complexity, where L is average length of word.
 	- Memory Footprint: Memory consumption in Trie would be less than N * L characters space, assuming that in a dictionary there are a lot of overlapping words.

##### Which one to pick?
My pick for this particular use case would be `Trie`, as I want to have reduced memory footprint as given number of words in `dictionary.txt` can be huge.
Alternatively, If I had to create a multi-process application I would have used Redis as shared storage and use it's Key Value Store to store dictionary words.

#### Challenge II
> In a matrix(4 X 4), to find if we can form a given word by moving to adjacent diagonal, horizontal or vetical position excluding the points that we have already visited.

I choose to use a recursive-approach(`models/boggle/game.rb:61 search()` method) with an additional matrix(`@visited`, keeps record of points we have already visited). Method `search` has breaking conditions given as
- Return if substring is not part of the word
- Return if any of the row or cols is going out of boundary
- If a string is complete match to the new string found via recursion, set a flag `@found` to be true and return any further recursive calls based on the flag.

#### Challenge III
> It is an extension to Challenge II where the created string(hereby denoted as STR) using `search` method can have wild-card matches as well

I have created a scoring method(`models/boggle/game.rb:87 match_score()`) for that, which returns

 - `score = 0` if STR is not a match to the given word
 - `score = 1` if STR is a complete match to the given word
 - `0 < score < 1` if STR is a sub-string of the given word

### Setup Instructions
Steps to setup the project from scratch.

- Pre-requisites
	- Ruby Language [Refer Here for Installation Instructions](https://www.ruby-lang.org/en/documentation/installation/)
	- Bundler (`gem install bundler`)

- Run application
```shell
cd boggle-problem-master
bundle install #Installs dependencies mentioned in Gemfile
ruby controllers/api.rb #Starts app-server at 4567 port
```

### Directory & File Structure
Application is built using sinatra (complete MVC architecture hasn't been followed, though I have made sure about code modularity)

 - Controllers: It is the app-configuration and app-server layer
 	- Concerns
 		- `response.rb`: Contains helper methods for making uniform response
 	- `api.rb`: Contains all API implementation
 - Models
 	- Boggle: Module to have 2 class enclosed into it.
 		- `board.rb`: Class to hold all of the board data in-memory class variables. Creates and validates the board.
 		- `game.rb`: Contains implementation to validate and play games.
 	- `dictionary.rb`: Acts as singleton class, fetches all words from `dictionary.txt` and creates an in-memory Trie.
 - Library(`lib`)
 	- `node.rb`: Node class to with-hold data neccesary to create Trie
 	- `trie.rb`: An implementation of Trie in Ruby

### API Documentation
All APIs only accept and responds in `content-type: application/json`
 
 - [Health Check](#health-check)
 - [Create Game](#create-game)
 - [Get Game](#get-game)
 - [Play Game](#play-game)

##### Health Check
 - method: GET
 - url: `/health`
 - response
 	- `status_code`: 200
	- `uptime`: elapsed time in seconds since server started
	- `games_generated`: Total number of games already generated
 
##### Create Game

 - method: POST
 - url: `/games`
 - request
 	- body
 		- `duration` (required)
 			- data-type: integer > 0
 			- description: time in seconds till game would be accepting request to play
 		- `random` (required)
 			- data-type: boolean(true/false)
 			- description: true means application will generate a random board or will use user provided board
 		- `board` (optional, if random is false, if sent empty with random true default board will be used(`test_board.txt`))
 			- data-type: string(comma seperated 16-characters `[A-Z & *]`)
 			- description: information on the board strucuture to be created
 - response
 	- Success(`status_code`: 201)
 		- body
 			- `id`: unique board id
 			- `token`: auth-token to verify user request
 			- `duration`: time in seconds for which the game is valid
 			- `board`: configuration of the board created at sever
 	- Failure(`status_code`: 400)
 		- body
 			- `message`: gives reason for failure

##### Get Game
 - method: GET
 - url: `/games/:id`
 - request
 	- url-parameters
 		- `id`: game id for which data is being requested
 - response
 	- Success(`status_code`: 200)
 		- body
 			- `id`: unique board id
 			- `token`: auth-token to verify user request
 			- `duration`: time in seconds for which the game is valid
 			- `board`: configuration of the board created at sever
 			- `time_left`: Time left to play the game
 			- `points`: Total points accumulated so far
 	- Failure(`status_code`: 404)
 		- body
 			- `message`: reason of failure

##### Play Game
 - method: POST
 - url: `/games/:id`
 - request
 	- url-parameters
 		- `id`: game id for which data is being requested
 	- body
 		- `token`: auth-token provided while creating the game
 		- `word`: word to be searched for on board
 - response
 	- Success(`status_code`: 200)
 		- body
 			- `id`: unique board id
 			- `token`: auth-token to verify user request
 			- `duration`: time in seconds for which the game is valid
 			- `board`: configuration of the board created at sever
 			- `time_left`: Time left to play the game
 			- `points`: Total points accumulated so far
 	- Failure(`status_code`: 400)
 		- body
 			- `message`: reason of failure