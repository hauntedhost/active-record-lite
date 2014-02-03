class MassObject
  def self.my_attr_accessor(*attributes)
    @attributes = attributes
    attr_accessor *attributes
  end

  def self.attributes
    @attributes || []
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
      else
        raise "mass assignment to unregistered attribute '#{attr_name}'"
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
