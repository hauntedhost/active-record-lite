require 'active_support/inflector'
require_relative 'inflector_custom.rb'

class AssocOptions
  attr_reader :class_name, :foreign_key, :primary_key

  def other_class
    class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end
