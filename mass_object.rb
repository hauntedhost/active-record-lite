class MassObject
  def self.set_attrs(*attributes)
    @attributes = attributes
    attr_accessor *attributes
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map { |row| self.new(row) }
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if attributes.include?(attr_name)
        operation = "#{attr_name}=".to_sym
        self.send(operation, value)
      end
    end
  end

  def attributes
    self.class.attributes
  end

  def table_name
    self.class.table_name
  end
end

if __FILE__ == $0
  class MyMassObject < MassObject
    set_attrs(:x, :y, :z)
  end

  obj = MyMassObject.new(:x => :x_val, :y => :y_val, :z => :z_val)
  p obj
end
