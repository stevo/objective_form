class ObjectiveForm::Base
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  class_attribute :pseudo_relations, :attributes

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

    pseudo_relations.each do |rel|
      instance_variable_set("@#{rel.name}", []) unless send(rel.name)
    end
  end

  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def persist!
    raise NotImplementedError
  end

  private

  def initialize_attribute_value(klass_or_proc, value)
    return value.to_s if klass_or_proc == String

    if klass_or_proc == Array
      return [] if value.blank?
      return Array.wrap(value)
    end

    if klass_or_proc.respond_to?(:new)
      klass_or_proc.new(value)
    elsif klass_or_proc.respond_to?(:call)
      klass_or_proc.call(value)
    else
      value
    end
  end

  class << self
    public

    def has_many(name, pseudo_record)
      store_relation(name, pseudo_record)
      define_relation_accessors(name, pseudo_record)
    end

    def attribute(name, klass_or_proc = String)
      store_attribute(name, klass_or_proc)
      define_attribute_accessors(name, klass_or_proc)
    end

    private

    def store_attribute(name, klass_or_proc)
      self.attributes ||= []
      self.attributes += Array.wrap(ObjectiveForm::Attribute.new(name, klass_or_proc))
    end

    def store_relation(name, pseudo_record)
      self.pseudo_relations ||= []
      self.pseudo_relations += Array.wrap(ObjectiveForm::PseudoRelation.new(name, pseudo_record))
    end

    def define_attribute_accessors(name, klass_or_proc)
      attr_reader name

      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", initialize_attribute_value(klass_or_proc, value))
      end
    end

    def define_relation_accessors(name, pseudo_record)
      attr_reader name

      define_method("#{name}=") do |values|
        Array.wrap(values).each do |value|
          pseudo_record_instance = pseudo_record.new(value)
          instance_variable_set("@#{name}", instance_variable_get("@#{name}") + [pseudo_record_instance])
        end
      end

      define_method("#{name}_attributes=") do |values|
        instance_variable_set("@#{name}", []) unless instance_variable_defined?("@#{name}")
        values.each do |_, attributes|
          next if attributes['_destroy'] and ::ActiveRecord::ConnectionAdapters::Column.value_to_boolean(attributes['_destroy'])
          pseudo_record_instance = pseudo_record.new(*attributes.except('_destroy').values)
          instance_variable_set("@#{name}", instance_variable_get("@#{name}") + [pseudo_record_instance])
        end
      end
    end
  end
end