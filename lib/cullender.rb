# require "elasticsearch"
require "tire"
require "cullender/core_ext/hash"
require "strong_parameters"
module Cullender

  module Controllers
    autoload :ScopedViews, 'cullender/controllers/scoped_views'
    autoload :FilterLogic, "cullender/controllers/filter_logic"
  end


	# The parent controller all Devise controllers inherits from.
	# Defaults to ApplicationController. This should be set early
	# in the initialization process and should be set to a string.
	mattr_accessor :parent_controller
	@@parent_controller = "ApplicationController"

	# The router Devise should use to generate routes. Defaults
	# to :main_app. Should be overriden by engines in order
	# to provide custom routes.
	mattr_accessor :router_name
	@@router_name = nil

	# Define a set of modules that are called when a mapping is added.
	mattr_reader :helpers
	@@helpers = Set.new
	# @@helpers << Cullender::Controllers::Helpers

	# Store scopes mappings.
	mattr_reader :mappings
	@@mappings = ActiveSupport::OrderedHash.new


	# Scoped views. Since it relies on fallbacks to render default views, it's
	# turned off by default.
	mattr_accessor :scoped_views
	@@scoped_views = false

	# Default way to setup Cullender. Run rails generate cullender:install to create
	# a fresh initializer with all configuration values.
	def self.setup
		yield self
	end

	# Regenerates url helpers considering Devise.mapping
	def self.regenerate_helpers!
		# Devise::Controllers::UrlHelpers.remove_helpers!
		# Devise::Controllers::UrlHelpers.generate_helpers!
	end


	# Small method that adds a mapping to Devise.
	def self.add_mapping(resource, options)
		mapping = Cullender::Mapping.new(resource, options)
		@@mappings[mapping.name] = mapping
		@@default_scope ||= mapping.name
		@@helpers.each { |h| h.define_helpers(mapping) }
		mapping
	end


	class Getter
		def initialize name
			@name = name
		end

		def get
			ActiveSupport::Dependencies.constantize(@name)
		end
	end

	def self.ref(arg)
		if defined?(ActiveSupport::Dependencies::ClassCache)
			ActiveSupport::Dependencies::reference(arg)
			Getter.new(arg)
		else
			ActiveSupport::Dependencies.ref(arg)
		end
	end
end

require 'cullender/mapping'
require "cullender/engine"