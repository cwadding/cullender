module Cullender
  module Controllers
    module FilterLogic
        def add_or_filter(key, params, field, should_raise = false)
          if params.present? && params.has_key?(key)
            if should_raise
              params[key] = {1 => params[key], 2 => add_operator(field)}
            else
              idx = params[key].keys.last.to_i + 1
              params[key].deep_merge!({idx => add_operator(field)})
            end
          else
            if should_raise
              params[key] = add_operator(field)
            else
              params[key] = add_operator(field)
            end
          end
        end

        def add_and_filter(key, params, field)
          clean_field(field) unless field.is_a? String
          if params.present? && params.has_key?(key)
            params[key].deep_merge!(add_operator(field))
          else
            params[key] = add_operator(field)
          end
        end

        def clean_field(field)

          field.each do |key, value|
            if value.is_a?(Hash)
              clean_field(value)
            else
              field.delete(key) if value.blank?
            end
          end
        end

        def remove_and_filter(key, params, field)
          if params.present? && params.has_key?(key)
            if field.is_a? String
              params[key].delete(field)
            else 
              params[key].deep_delete(field)
            end
          end
        end

        def add_operator(field)
          if field.is_a?(Hash)
            hash = {}
            field.each do |key, value|
              if ["o", "v"].include?(key)
                hash = field
                break
              else
                hash.merge!({key => add_operator(value)}) unless ["o", "v"].include?(key)
              end
            end
          elsif
            hash = {field => {"o" => nil}} 
          end
          hash
        end

        def apply_filter_actions(name, filter_params, params)
          # debugger
          updated = false
          if params.has_key?("or") && (params["or"].has_key?("commit") || params["or"].has_key?("raise"))
            nfilter = params.delete("or")
            should_raise = nfilter.has_key?("raise")
            add_or_filter(name, filter_params, should_raise ? nfilter["raise_field"] : nfilter["field"],  should_raise) if (nfilter["field"].present? || nfilter["raise_field"].present?)
            updated = true
          elsif params.has_key?("and") && params["and"].has_key?("commit")
            nfilter = params.delete("and")
            add_and_filter(name, filter_params, nfilter["field"]) if nfilter["field"].present?
            updated = true
          elsif params.has_key?("remove")
            nfilter = params.delete("remove")
            remove_and_filter(name, filter_params, nfilter)
            updated = true
          end
          updated
        end
    end
  end
end