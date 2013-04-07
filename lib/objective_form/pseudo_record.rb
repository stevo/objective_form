module ObjectiveForm
  class PseudoRecord < Struct
    class_attribute :_fields
    attr_writer :_destroy

    def self.new(*args)
      fields = args.extract_options!
      super(*fields.keys).tap do |klass|
        klass._fields = fields
      end
    end

    def persisted?
      false
    end

    def _destroy
      false
    end
  end
end