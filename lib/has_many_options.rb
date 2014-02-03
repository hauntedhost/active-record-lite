require_relative 'assoc_options'

class HasManyOptions < AssocOptions
  def initialize(assoc_name, self_class, params = {})
    @class_name = params[:class_name] || assoc_name.to_s.singularize.camelize
    @foreign_key = params[:foreign_key] || "#{self_class.underscore}_id".to_sym
    @primary_key = params[:primary_key] || :id
  end

  def type
    :has_many
  end
end
