require 'active_support/inflector'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name.underscore
  end

  def self.table_name
    @table_name
  end

  def self.all
    query = <<-SQL
    SELECT *
    FROM #{table_name}
    SQL
    rows = DBConnection.execute(query)
    # OPTIMIZE: parse_all(rows)
    rows.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    query = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE id = ?
    SQL
    row = DBConnection.execute(query, id).first
    row.nil? ? nil : self.new(row)
  end

  def attributes_hash
    # build hash of non-nil attributes, minus :id
    row = {}
    attributes.each do |attr|
      value = self.send(attr)
      row[attr] = value unless value.nil? || attr == :id
    end
    row
  end

  # OPTIMIZE: no point to these next two
  def attributes_keys
    attributes_hash.keys
  end

  def attributes_values
    attributes_hash.values
  end

  def create
    p "CREATE"

    # extract columns, values, question marks
    columns = attributes_keys.join(", ")
    values = attributes_values
    question_marks = (['?'] * values.count).join(", ")

    # build and execute query
    query = <<-SQL
      INSERT INTO #{table_name} (#{columns})
      VALUES (#{question_marks})
    SQL
    DBConnection.execute(query, *values)

    # try to update returned id for instance
    self.id = DBConnection.last_insert_row_id
    self
    # self.send(:id=, id)
    # id
  end

  def update
    p "UPDATE"
    # { :name" => "Sebastian", :owner_id" => 5 }
    set = attributes_keys.map { |key| "#{key} = ?" }.join(", ")
    values = attributes_values

    # build and execute query
    query = <<-SQL
      UPDATE #{table_name}
      SET #{set}
      WHERE id = #{id}
    SQL
    DBConnection.execute(query, *values)
    self
  end

  def save
    id ? update : create
  end

end

if __FILE__ == $0
  # == MY TESTS
  # class Cat < SQLObject
  #   set_table_name("cats")
  #   set_attrs(:id, :name, :owner_id)
  # end
  #
  # cats_db_file_name = "cats.db"
  # DBConnection.open(cats_db_file_name)
  #
  # p Cat.all
  # p Cat.find(2)
  #
  # cat = Cat.new(:name => "Sebastian", :owner_id => 5)
  # p "id: #{cat.id} # before create"
  # cat.create
  # p "id: #{cat.id}"
  # p "name: #{cat.name}"
  # p "owner_id: #{cat.owner_id}"
  #
  # cat.name = "Aleister"
  # cat.update
  # p "name: #{cat.name}"

  # == TESTS
  cats_db_file_name = "cats.db"
  DBConnection.open(cats_db_file_name)

  class Cat < SQLObject
    set_table_name("cats")
    set_attrs(:id, :name, :owner_id)
  end

  class Human < SQLObject
    set_table_name("humans")
    set_attrs(:id, :fname, :lname, :house_id)
  end

  p Human.find(1)
  p Cat.find(1)
  p Cat.find(2)

  p Human.all
  p Cat.all

  c = Cat.new(:name => "Gizmo", :owner_id => 1)
  c.save # create
  c.save # update

end
