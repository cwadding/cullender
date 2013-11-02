module Cullender
  class Rule < ActiveRecord::Base
  	include ActiveModel::ForbiddenAttributesProtection
  	before_create :add_event_percolation
  	before_update :modify_event_percolation
  	before_destroy :remove_event_percolation


	serialize :triggers, Hash

	validates :name, :presence => true, :uniqueness => true, :length => {
	    :minimum => 4,
	    :maximum => 20
	}

# basic operators ["term", "terms", "string", "range", "prefix", "fuzzy"]
	OPERATORS = {
		"text_field" => {
			I18n.t("cullender.operators.term") => "term",
			I18n.t("cullender.operators.prefix") => "prefix"
		},
		"number_field" => {
			I18n.t("cullender.operators.gt") => "gt",
			I18n.t("cullender.operators.gte") => "gte",
			I18n.t("cullender.operators.lt") => "lt",
			I18n.t("cullender.operators.lte") => "lte",
			I18n.t("cullender.operators.eq") => "term"
		},
		"range_field" => {
			I18n.t("cullender.operators.gt") => "gt",
			I18n.t("cullender.operators.gte") => "gte",
			I18n.t("cullender.operators.lt") => "lt",
			I18n.t("cullender.operators.lte") => "lte",
			I18n.t("cullender.operators.eq") => "term"
		},
		"date" => {
			I18n.t("cullender.operators.from") => "from",
			I18n.t("cullender.operators.to") => "to"
		},
		"datetime" => {
			I18n.t("cullender.operators.from") => "from",
			I18n.t("cullender.operators.to") => "to"
		},
		"select" => {
			I18n.t("cullender.operators.is") => "term",
			I18n.t("cullender.operators.is_not") => "term"
		},
		"check_box" => {
			I18n.t("cullender.operators.eq") => "is"
		}
	}

	FILTER_MAP = {
		"term" => "==",
		"prefix" => "starts with",
		"gt" => ">",
		"gte" => ">=",
		"lt" => "<",
		"lte" => "<=",
		"from" => ">=",
		"to" => "<="
	}

	FIELD_TYPE_MAP = {
		'string' => 'text_field',
		'integer' => 'number_field',
		'long' => 'number_field',
		'double' => 'number_field',
		'float' => 'number_field',
		'date' => 'date',
		'boolean' => 'check_box'
	}

  
	# This method searches elastic search for events that match this specific
	def fire(event)
		event.add_labels(self.labels) unless self.labels.empty?
		# send any notifications
	end

	#  converts the current rule to a proc accepting an an elastic search query object
	def to_query_proc
		Proc.new do
			self.to_query
		end
	end

	def to_query
		query = ::Tire::Search::Query.new
		if triggers.present?
			
			# check if there is only one field
			count = number_of_fields
			if count > 1
				# complex operators ["boolean", "filtered", "dis_max", "nested"]
				convert_to_boolean(query)
			elsif count == 1
				query = convert_to_basic_query(query, triggers.first[0], triggers.first[1])
			else

			end
		end
		query
	end


	def convert_to_boolean(query, params = self.triggers)
		query.boolean do |bool|
			params.each do |key, values|
				if key.to_i > 0
					bool.should do |q|
						convert_to_boolean(q, values)
					end
				else
					bool.must do |q|
						convert_to_basic_query(q, key, values)
					end
				end
			end
		end
		query
	end



	# def to_filter
	# 	search = ::Tire::Search::Search.new
	# 	filters_to_or = []
	# 	search.query.all
	# 	triggers.each do |key, value|
	# 		if value.has_key?("o") && value.has_key?("v")
	# 			search.filter :term, key.to_sym => value["v"]
	# 		else
	# 			f = self.to_search(::Tire::Search::Search.new, value).to_hash
	# 			filters_to_or << f[:filter]
	# 		end
	# 	end
	# 	search.filter :or, filters_to_or unless filters_to_or.empty?
	# 	search
	# end

	private

	def add_event_percolation
		begin
			# debugger
			response = Event.index.register_percolator_query(self.name, :query => self.to_query.to_hash)
			!response.nil?
		rescue Exception => e
			false
		end
	end

	def modify_event_percolation
		begin
			response = Event.index.unregister_percolator_query(self.name)
			response = Event.index.register_percolator_query(self.name, :query => self.to_query.to_hash)
			!response.nil?
		rescue Exception => e
			false
		end
	end

	def remove_event_percolation
		begin
			response = Event.index.unregister_percolator_query(self.name, :query => self.to_query.to_hash)
			!response.nil?
		rescue Exception => e
			false
		end
	end
	private

	##
	# Calculate the number of fields in the triggers hash
	def number_of_fields(params = self.triggers)
		if params.present?
			params.values.inject(0) do |sum, value|
				if value.is_a?(Hash)
					# puts value.keys.inspect
					sum + (value.keys.include?("o") ? 1 : number_of_fields(value) )
				else
					sum + 1
				end
			end
		else
			0
		end
	end

	def convert_to_basic_query(query, field_name, params = {})
		# basic operators ["term", "terms", "string", "range", "prefix", "fuzzy"]
		if (query.is_a?(Tire::Search::Query))
			operator = params["o"]
			value = params["v"]
			query.send(operator.to_sym, field_name, value)
		else
	      raise ArgumentError, "Argument is not a Tire::Search::Search."
	    end
	    query
	end

  end
end
