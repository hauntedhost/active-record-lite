require 'active_support/inflector'
require_relative './db_connection'
require_relative './mass_object'
require_relative './sql_object'
require_relative './associatable'

module Searchable
  def where(params)
    # OPTIMIZE: raise error if any param key does not exist
    #attributes.include?(key)

    where_clauses = params.keys.map { |key| "#{key} = ?" }.join( " AND ")
    values = params.values

    query = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE #{where_clauses}
    SQL
    rows = DBConnection.execute(query, *values)
    # OPTIMIZE: add parse_all(rows)
    rows.map do |row|
      self.new(row)
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
  end

  # define human model
  class Human < SQLObject
    set_table_name("humans")
    set_attrs(:id, :fname, :lname, :house_id)
  end

  p Cat.where(:name => "Breakfast")
  p Human.where(:fname => "Matt", :house_id => 1)

end
