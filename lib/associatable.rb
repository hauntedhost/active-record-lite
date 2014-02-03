require 'active_support/inflector'
require_relative 'inflector_custom.rb'
require_relative 'belongs_to_options.rb'
require_relative 'has_many_options.rb'

module Associatable
  def assoc_params
    @assoc_params ||= {}
  end

  def belongs_to(assoc_name, params = {})
    aps = BelongsToOptions.new(assoc_name, params)
    assoc_params[assoc_name] = aps

    define_method(assoc_name) do
      value = self.send(aps.foreign_key)
      query = <<-SQL
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.primary_key} = ?
        LIMIT 1
      SQL

      puts "[QUERY] #{query} => #{value}" if ENV['DEBUG']
      row = DBConnection.execute(query, value).first
      aps.other_class.new(row)
    end
  end

  def has_many(assoc_name, params = {})
    self_class = name
    aps = HasManyOptions.new(assoc_name, self_class, params)
    assoc_params[assoc_name] = aps

    define_method(assoc_name) do
      value = self.send(aps.primary_key)
      query = <<-SQL
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.other_table}.#{aps.foreign_key} = ?
      SQL

      puts "[QUERY] #{query} => #{value}" if ENV['DEBUG']
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

      puts "[QUERY] #{query} => #{value}" if ENV['DEBUG']
      row = DBConnection.execute(query, value).first
      sps.class_name.constantize.new(row)
    end
  end
end
