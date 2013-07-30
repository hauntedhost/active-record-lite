require 'active_support/inflector'
require_relative './db_connection'
require_relative './mass_object'
require_relative './sql_object'
require_relative './searchable'

class AssocParams
  attr_reader :class_name, :foreign_key, :primary_key

  def other_class
    class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @class_name = params[:class_name] || name.to_s.camelize
    @foreign_key = params[:foreign_key] || "#{name.to_s}_id" 
    @primary_key = params[:primary_key] || :id
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @class_name = params[:class_name] || name.to_s.singularize.camelize
    @foreign_key = params[:foreign_key] || "#{self_class.name}_id"
    @primary_key = params[:primary_key] || :id
  end

  def type
    :has_many
  end
end

module Associatable
  
  def assoc_params
  	@assoc_params ||= {}
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    assoc_params[name] = aps

    define_method(name) do
	    value = self.send(aps.foreign_key)
      query = <<-SQL
	      SELECT *
	      FROM #{aps.other_table}
	      WHERE #{aps.primary_key} = ?
	      LIMIT 1
      SQL
      puts "#{query} => #{value}"
      row = DBConnection.execute(query, value).first
			aps.other_class.new(row)
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self.class)
  	assoc_params[name] = aps

    define_method(name) do
	    value = self.send(aps.primary_key)
      query = <<-SQL
	      SELECT *
	      FROM #{aps.other_table}
	      WHERE #{aps.other_table}.#{aps.foreign_key} = ?
      SQL
      puts "#{query} => #{value}"
      rows = DBConnection.execute(query, value)
      rows.map do |row|
        aps.other_class.new(row)
      end
    end
  end

  def has_one_through(name, through, source)
  	define_method(name) do
	  	tps = self.class.assoc_params[through]
  		sps = tps.other_class.assoc_params[source]
  		value = self.send(tps.foreign_key)

  		query = <<-SQL
				SELECT #{sps.other_table}.*
				FROM #{sps.other_table}
				INNER JOIN #{tps.other_table}
				ON #{tps.other_table}.#{sps.foreign_key} = #{sps.other_table}.#{sps.primary_key}
				WHERE #{tps.other_table}.#{tps.primary_key} = ?
				LIMIT 1;
			SQL
			puts "#{query} => #{value}"

			row = DBConnection.execute(query, value).first
			sps.class_name.constantize.new(row)
  	end
  end
end

if __FILE__ == $0
  # open database connection
  cats_db_file_name = "cats.db"
  DBConnection.open(cats_db_file_name)

  # define cat model
  class Cat < SQLObject
    set_table_name("cats")
    set_attrs(:id, :name, :owner_id)

    belongs_to :human,
      :foreign_key => :owner_id #,
      # :class_name => "Human",
      # :primary_key => :id

    has_one_through :house, :human, :house
  end

  # define human model
  class Human < SQLObject
    set_table_name("humans")
    set_attrs(:id, :fname, :lname, :house_id)

    has_many :cats,
      :foreign_key => :owner_id #,
      # :class_name => "Cat",
      # :primary_key => :id

    belongs_to :house #,
      # :class_name => "House",
      # :foreign_key => :house_id,
      # :primary_key => :id
  end

  # define house model
  class House < SQLObject
    set_table_name("houses")
    set_attrs(:id, :address, :house_id)
  end

  # find cat and human
  cat = Cat.find(3)						# 3 | Esther 	| 2
  human = Human.find(2)				# 2 | Alli		| Crawford | 1

  puts "cat.name: #{cat.name}"
  puts "human.fname: #{human.fname}"

  puts "\nbelongs_to:"
	puts "-----------"
  puts "cat.human.fname:" 
  puts cat.human.fname
  puts "human.house.address:"
  puts human.house.address

  puts "\nhas_many:"
  puts "---------"
  puts "human.cats"
  human.cats.each do |cat|
  	puts cat.name
  end

  puts "has_one_through:"
	puts "----------------"
	puts "cat.house.address: #{cat.house.address}"

end
