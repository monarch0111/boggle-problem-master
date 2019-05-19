require_relative "./node.rb"

class Trie
  
  def initialize
    @root = Node.new
  end

  def set(word)
    word.upcase!
    parent = @root
    word.chars.each do |char|
      parent.children[char] = Node.new if parent.children[char].nil?
      parent = parent.children[char]
    end
    parent.end_of_word = true
  end

  def get(word)
    word.upcase!
    parent = @root
    word.chars.each do |char|
      return false if parent.children[char].nil?
      parent = parent.children[char]
    end
    parent.end_of_word
  end
end
