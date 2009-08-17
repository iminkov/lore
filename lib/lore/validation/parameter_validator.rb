
require('lore/validation/type_validator')
require('lore/exception/invalid_parameter')

module Lore
module Validation
  
  class Parameter_Validator # :nodoc:

    PG_BOOL                 = 16
    PG_SMALLINT             = 21
    PG_INT                  = 23
    PG_TEXT                 = 25
    PG_VARCHAR              = 1043
    PG_TIMESTAMP_TIMEZONE   = 1184

    @logger = Lore.logger
    
    #############################################################
    # To be used inside Table_Accessor with
    # Validator.invalid_params(this, @attribute_values)
    # or e.g. in a dispatcher with
    # Validator.invalid_params(Some_Klass, parameter_hash)
    # 
    def self.invalid_params(klass, value_hash)
    
      invalid_params = Hash.new
      explicit_attributes = klass.__attributes__.required
      constraints = klass.__attributes__.constraints
      attribute_settings = klass.__attributes__
      required = attribute_settings.required

      attribute_settings.types.each_pair { |table, fields|
        begin
          validate_types(fields, value_hash[table], required[table])
        rescue Lore::Exceptions::Invalid_Types => ip
          invalid_params[table] = ip
        end
      }
      
      attribute_settings.constraints.each_pair { |table, fields|
        begin
          validate_constraints(fields, value_hash[table])
        rescue Lore::Exceptions::Unmet_Constraints => ip
          invalid_params[table] = ip
        end
      }
      if invalid_params.length == 0 then return true end
        
      raise Lore::Exceptions::Invalid_Field_Values.new(klass, invalid_params)

    end

    def self.validate_types(type_codes, table_value_hash, required)
      invalid_types = {} 
      value = false
      type_validator = Type_Validator.new()
      type_codes.each_pair { |field, type|
        field = field.to_sym
        nil_allowed = (!required || !required[field])

        value = table_value_hash[field]
        # Replace whitespaces and array delimiters to check for real value length
        value_nil = (value.nil? || value.to_s.gsub(/\s/,'').gsub(/[{}]/,'').length == 0)
     #  puts "Validate #{field}: Nil allowed: #{nil_allowed}, value: #{value}, value nil: #{value_nil}"
        # Is value missing? 
        if (!nil_allowed && value_nil) then 
          invalid_types[field] = :missing
        # If so: Is value of valid type? 
        elsif !type_validator.typecheck(type, value, nil_allowed) then
          invalid_types[field] = type
        end
        
      }
      if invalid_types.keys.length > 0 then
          raise Lore::Exceptions::Invalid_Types.new(invalid_types)
      end
      return true
    end

    def self.validate_constraints(table_constraints, table_value_hash)
      unmet_constraints = {}
      table_constraints.each_pair { |attrib, rules|
        value = table_value_hash[attrib.to_s]
        rules.each_pair { |rule, rule_value|
          if rule == :minlength && value.to_s.length < rule_value then
            unmet_constraints[attrib] = :minlength
          end
          if rule == :maxlength && value.to_s.length > rule_value then
            unmet_constraints[attrib] = :maxlength
          end
          if rule == :format && rule_value.match(value).nil? then
            unmet_constraints[attrib] = :format
          end
        }
      }
      if unmet_constraints.length > 0 then
        raise Lore::Exceptions::Unmet_Constraints.new(unmet_constraints)
      end
      return true
    end

  end

end # module
end # module
