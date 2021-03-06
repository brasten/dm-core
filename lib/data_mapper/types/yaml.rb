require 'yaml'

module DataMapper
  module Types
    class Yaml < DataMapper::Type
      primitive String
      size 65535
      lazy true

      def self.load(value)
        if value.nil?
          nil
        elsif value.is_a?(String)
          ::YAML.load(value)
        else
          raise ArgumentError.new("+value+ must be nil or a String")
        end
      end

      def self.dump(value)
        if value.nil?
          nil
        elsif value.is_a?(String) && value =~ /^---/
          value
        else
          ::YAML.dump(value)
        end
      end
    end # class Yaml
  end # module Types  
end # module DataMapper