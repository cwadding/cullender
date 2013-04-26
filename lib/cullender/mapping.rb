module Cullender
  # Responsible for handling cullender mappings and routes configuration. Each
  # resource configured by cullender_for in routes is actually creating a mapping
  # object. You can refer to cullender_for in routes for usage options.
  #
  # The required value in cullender_for is actually not used internally, but it's
  # inflected to find all other values.
  #
  #   map.cullender_for :events
  #   mapping = Cullender.mappings[:event]
  #
  #   mapping.name #=> :event
  #   # is the scope used in controllers and warden, given in the route as :singular.
  #
  #   mapping.as   #=> "events"
  #   # how the mapping should be search in the path, given in the route as :as.
  #
  #   mapping.to   #=> Event
  #   # is the class to be loaded from routes, given in the route as :class_name.
  #
  #   mapping.modules  #=> [:authenticatable]
  #   # is the modules included in the class
  #
  class Mapping #:nodoc:
    attr_reader :singular, :scoped_path, :path, :controllers, :path_names,
                :class_name, :sign_out_via, :format, :used_routes, :used_helpers, :failure_app

    alias :name :singular

    # Receives an object and find a scope for it. If a scope cannot be found,
    # raises an error. If a symbol is given, it's considered to be the scope.
    def self.find_scope!(duck)
      case duck
      when String, Symbol
        return duck
      when Class
        Cullender.mappings.each_value { |m| return m.name if duck <= m.to }
      else
        Cullender.mappings.each_value { |m| return m.name if duck.is_a?(m.to) }
      end

      raise "Could not find a valid mapping for #{duck.inspect}"
    end

    def self.find_by_path!(path, path_type=:fullpath)
      Cullender.mappings.each_value { |m| return m if path.include?(m.send(path_type)) }
      raise "Could not find a valid mapping for path #{path.inspect}"
    end

    def initialize(name, options) #:nodoc:
      @scoped_path = options[:as] ? "#{options[:as]}/#{name}" : name.to_s
      @singular = (options[:singular] || @scoped_path.tr('/', '_').singularize).to_sym

      @class_name = (options[:class_name] || name.to_s.classify).to_s
      @klass = Cullender.ref(@class_name)

      @path = (options[:path] || name).to_s
      @path_prefix = options[:path_prefix]

      @format = options[:format]

      # default_failure_app(options)
      default_controllers(options)
      default_path_names(options)
      default_used_route(options)
      default_used_helpers(options)
    end

    # Gives the class the mapping points to.
    def to
      @klass.get
    end

    def routes
      @routes ||= ["rule"]#.compact.uniq
    end

    def fullpath
      "/#{@path_prefix}/#{@path}".squeeze("/")
    end

    private

    def default_failure_app(options)
      @failure_app = options[:failure_app] || Cullender::FailureApp
      if @failure_app.is_a?(String)
        ref = Cullender.ref(@failure_app)
        @failure_app = lambda { |env| ref.get.call(env) }
      end
    end

    def default_controllers(options)
      mod = options[:module] || "cullender"
      @controllers = Hash.new { |h,k| h[k] = "#{mod}/#{k}" }
      @controllers.merge!(options[:controllers]) if options[:controllers]
      @controllers.each { |k,v| @controllers[k] = v.to_s }
    end

    def default_path_names(options)
      @path_names = Hash.new { |h,k| h[k] = k.to_s }
      @path_names[:rules] = ""
      @path_names.merge!(options[:path_names]) if options[:path_names]
    end

    def default_constraints(options)
      @constraints = Hash.new
      @constraints.merge!(options[:constraints]) if options[:constraints]
    end

    def default_defaults(options)
      @defaults = Hash.new
      @defaults.merge!(options[:defaults]) if options[:defaults]
    end

    def default_used_route(options)
      singularizer = lambda { |s| s.to_s.singularize.to_sym }

      if options.has_key?(:only)
        @used_routes = self.routes & Array(options[:only]).map(&singularizer)
      elsif options[:skip] == :all
        @used_routes = []
      else
        @used_routes = self.routes - Array(options[:skip]).map(&singularizer)
      end
    end

    def default_used_helpers(options)
      singularizer = lambda { |s| s.to_s.singularize.to_sym }

      if options[:skip_helpers] == true
        @used_helpers = @used_routes
      elsif skip = options[:skip_helpers]
        @used_helpers = self.routes - Array(skip).map(&singularizer)
      else
        @used_helpers = self.routes
      end
    end
  end
end
