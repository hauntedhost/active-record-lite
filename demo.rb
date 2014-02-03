require_relative 'lib/active_record_lite'

# show verbose queries
ENV['DEBUG'] = 'true'

# open database connection
DBConnection.open("db/cats.sqlite3")

# define cat model
class Cat < SQLObject
  my_attr_accessor :id, :name, :owner_id

  belongs_to :human, foreign_key: :owner_id
  has_one_through :house, :human, :house
end

# define human model
class Human < SQLObject
  set_table_name "humans" # override table_name (default is "humans" anyway)
  my_attr_accessor :id, :fname, :lname, :house_id

  has_many :cats, foreign_key: :owner_id
  belongs_to :house
end

# define house model
class House < SQLObject
  my_attr_accessor :id, :address

  # specify class_name, foreign_key, primary_key (defaults are identical in this case)
  has_many :humans,
    class_name: "Humans",
    foreign_key: :house_id,
    primary_key: :id
end

puts "simply find queries:"
puts "-------------------"
cat = Cat.find(2)
puts "cat = Cat.find(2)       => #{cat.inspect}"
puts "cat.name                => #{cat.name}"

puts

human = Human.find(1)
puts "human = Human.find(1)   => #{human.inspect}"
puts "human.fname             => #{human.fname}"

puts

puts "belongs_to associations:"
puts "-----------------------"
puts "cat.human               => #{cat.human.inspect}"
puts "cat.human.fname:        => #{cat.human.fname}"
puts "human.house.address:    => #{human.house.address}"

puts

puts "has_many associations:"
puts "---------------------"
puts "human.cats              => #{human.cats.inspect}"

puts

puts "has_one_through associations:"
puts "----------------------------"
puts "cat.house               => #{cat.house.inspect}"
puts "cat.house.address:      => #{cat.house.address}"
