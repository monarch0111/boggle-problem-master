class Node
  attr_accessor :children, :end_of_word

  def initialize
    @children = {}
    @end_of_word = false
  end
end