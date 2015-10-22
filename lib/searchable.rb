module Searchable
  def where(params)
    # OPTIMIZE: raise error if any param key does not exist
    # e.g., raise 'NOPE' unless attributes.include?(key)

    where_clauses = params.keys.map { |key| "#{key} = ?" }.join(' AND ')
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
