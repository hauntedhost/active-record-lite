require 'active_support/inflector'
require_relative 'db_connection'
require_relative 'mass_object'
require_relative 'searchable'
require_relative 'associatable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name.underscore
  end

  def self.table_name
    @table_name || self.name.tableize
  end

  def self.all
    query = <<-SQL
      SELECT *
      FROM #{table_name}
    SQL

    puts "[QUERY] #{query}" if ENV['DEBUG']
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

    puts "[QUERY] #{query} => #{id}" if ENV['DEBUG']
    row = DBConnection.execute(query, id).first
    row.nil? ? nil : self.new(row)
  end

  def insert
    # extract columns, values, question marks
    columns = attribute_keys.join(", ")
    values = attribute_values
    question_marks = (['?'] * values.count).join(", ")

    # build and execute query
    query = <<-SQL
      INSERT INTO #{table_name} (#{columns})
      VALUES (#{question_marks})
    SQL

    puts "[QUERY] #{query}" if ENV['DEBUG']
    DBConnection.execute(query, *values)
    # try to update returned id for instance
    self.id = DBConnection.last_insert_row_id
    self
  end

  def update
    set = attribute_keys.map { |key| "#{key} = ?" }.join(", ")
    values = attribute_values

    # build and execute query
    query = <<-SQL
      UPDATE #{table_name}
      SET #{set}
      WHERE id = #{id}
    SQL

    puts "[QUERY] #{query}" if ENV['DEBUG']
    DBConnection.execute(query, *values)
    self
  end

  def save
    id ? update : insert
  end

  def attribute_hash
    # build hash of non-nil attributes
    row = {}
    attributes.each do |attr|
      value = self.send(attr)
      row[attr] = value unless value.nil?
    end
    row
  end

  def attribute_keys
    attribute_hash.keys
  end

  def attribute_values
    attribute_hash.values
  end
end
