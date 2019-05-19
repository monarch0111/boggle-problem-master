require_relative "../lib/trie.rb"

class Dictionary

  TRIE = Trie.new

  File.foreach(__dir__ + "/../dictionary.txt") do |line|
    TRIE.set(line.gsub("\n", ""))
  end

  def self.search(word)
    TRIE.get(word)
  end

end