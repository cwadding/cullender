module Cullender
  module RulesHelper


	  def render_property_tree(name,  mapping, hash, options = {}, hierarchy = [], &block)
	    options.merge!(:class => "group level_#{hierarchy.length}")
	    last_key =  hash.keys.last
	    html = content_tag :div, options do
	    hash.each do |field, value|
	      if value.keys.include?("o")
	      	property_options = mapping.has_key?(field) ? mapping[field] : {}
	        block.call property_item(name, field, property_options, value, hierarchy), last_key == field ? 1 : -1, hierarchy
	      else
	        hierarchy.push(field)
	        block.call render_property_tree(name, mapping, value, {}, hierarchy, &block), last_key == field ? 0 : -1, hierarchy
	      end
	    end
	    end if hash.present?
	    hierarchy.pop
	    html
	  end

	  def extract_field_type(options)
	  	options.has_key?(:type) && Cullender::Rule::FIELD_TYPE_MAP.has_key?(options[:type]) ? Cullender::Rule::FIELD_TYPE_MAP[options[:type]] : "text_field" 
	  end

		# type = Event.property_types.has_key?(field) ? Event.property_types[field] : "string" #Event::FIELDTYPE_MAP[column.datatype]
	  def property_item(name, field, options, value_hash = {}, hierarchy = [])
	  	fieldtype = extract_field_type(options)
		prefix = nested_property_prefix(hierarchy, name)
		operator = value_hash['o'] || nil
		value = value_hash['v'] || nil
		content_tag :div, :class => "item #{field.to_s.parameterize}" do
			submit_tag("-", :name => "remove#{nested_property_prefix(hierarchy, "")}[#{field}]", :class => 'btn') +
			label_tag(field, field, {:for => "#{prefix}[#{field}][v]"}) +
			select_tag( "#{prefix}[#{field}][o]", options_for_select(Cullender::Rule::OPERATORS[fieldtype], operator), :class => "operator") +
			property_value_field(field, fieldtype, value, options, prefix)
		end
	  end

	  def link_to_filter(attribute, value, options = {})
	    copy_of_params = deep_clone(params)
	    copy_of_params.deep_merge!({:filter => {attribute.to_sym => {"v" => value}}})
	    link_to_unless( params.has_key?(:filter) && params[:filter].has_key?(attribute), value, copy_of_params, options)
	  end
	  
	  def link_to_remove_filter(attribute, value, options = {})
	    condition = params.has_key?(:filter) && params[:filter].has_key?(attribute.to_s) && params[:filter][attribute.to_s]['v'].to_s == value.to_s
	    copy_of_params = deep_clone(params)  
	    copy_of_params[:filter].delete(attribute)
	    link_to( text_with_close_btn("#{attribute}=#{value}"), copy_of_params, options)
	  end

	  def remove_filter_link(attribute, value, count, options = {})
	    copy_of_params = deep_clone(params)
	    if params.has_key?(:filter) && params[:filter].has_key?(attribute.to_s) && params[:filter][attribute.to_s]['v'].to_s == value.to_s
	      copy_of_params[:filter].delete(attribute.to_s)
	      link_to "remove", copy_of_params, options
	    else
	      content_tag(:span, count, options)
	    end
	  end

	  def cullender_collection_or_select(collection, hierarchy = [], options = {})
	    is_base = options.delete(:base)
		prefix = nested_property_prefix(hierarchy)
		content_tag :div, :class => "add_group" do
			select_tag( "or[#{"raise_" if is_base}field]#{prefix}", options_for_select(collection), :class => "column_select_field") + 
			submit_tag("OR", :name => "or#{is_base ? "[raise]" : "[commit]"}#{prefix}", :class => 'btn')
		end
	  end


	  def cullender_collection_and_select(collection, hierarchy = [], options = {})
		prefix = nested_property_prefix(hierarchy)
		content_tag :div, :class => "add_filter" do
			select_tag( "and[field]#{prefix}", options_for_select(collection), :class => "column_select_field") + 
			submit_tag("AND", :name => "and[commit]#{prefix}", :class => 'btn')
		end
	  end

	  def extract_triggers(params)
	  	if params.has_key?("triggers")
	  		params["triggers"]
	  	elsif params.has_key?("rule") && params["rule"].has_key?("triggers")
			params["rule"]["triggers"]
	  	end
	  end


	def property_value_field(field, type, value = nil, options = {}, prefix = '')
		default = options.delete(:default)
		case type
		when "number_field", "range_field", "text_field", "check_box"
			send("#{type}_tag".to_sym, "#{prefix}[#{field}][v]", value, {:class => "value"} )
		when "select"
			select_tag("#{prefix}[#{field}][v]", options_for_select({}, value), {:class => "value"}) 
		when "datetime"
			select_datetime set_datetime(value, default), {:class => "value", :prefix => "#{prefix}[#{field}][v]"}
		when "date"
			select_date set_date(value, default), {:class => "value", :prefix => "#{prefix}[#{field}][v]"}
		else #this includes Event::TEXT and any other field type
			text_field_tag "#{prefix}[#{field}][v]", value, {:class => "value"}
		end
	end


		def filter_to_s(key, value)
			"#{key} #{Rule::FILTER_MAP[value["o"]]} #{value["v"]}" if value.has_key?("o") && value.has_key?("v")
		end

		# nest is an array of values of the hierarchy
		def nested_property_prefix(hierarchy, prefix = nil)
			"#{prefix}#{hierarchy.inject("") {|result, item| result += "[#{item}]"}}"
		end

	    def formatted_triggers(hash)
			ands = []
			ors = []
			hash.each do |key, value|
				if value.keys.include?("o")
					ands << filter_to_s(key, value)
				else
					ors << formatted_triggers(value)
				end
			end if hash.present?
			ors.empty? ? "("+ ands.join(" AND ") + ")" : "(" + ors.join(" OR ") + ")"
		end

		private

		  def deep_clone(obj)
		    Marshal.load(Marshal.dump(obj))
		  end
  end
end
