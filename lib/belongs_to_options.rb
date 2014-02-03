require_relative 'assoc_options'

class BelongsToOptions < AssocOptions
  def initialize(assoc_name, params = {})
    @class_name = params[:class_name] || "#{assoc_name}".camelize
    @foreign_key = params[:foreign_key] || "#{assoc_name}_id".to_sym
    @primary_key = params[:primary_key] || :id
  end

  def type
    :belongs_to
  end
end
