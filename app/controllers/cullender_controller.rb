# All Cullender controllers are inherited from here.
class CullenderController < Cullender.parent_controller.constantize
  include Cullender::Controllers::ScopedViews

  helpers = %w(resource scope_name resource_name
               resource_class resource_params cullender_mapping)
  hide_action *helpers
  helper_method *helpers

  prepend_before_filter :assert_is_cullender_resource!
  respond_to *Mime::SET.map(&:to_sym) if mimes_for_respond_to.empty?

  # Gets the actual resource stored in the instance variable
  def resource
    instance_variable_get(:"@#{resource_name}")
  end

  # Proxy to cullender map name
  def resource_name
    cullender_mapping.name
  end
  alias :scope_name :resource_name

  # Proxy to cullender map class
  def resource_class
    cullender_mapping.to
  end

  def resource_params
    params[resource_name]
  end

  # Attempt to find the mapped route for cullender based on request path
  def cullender_mapping
    @cullender_mapping ||= request.env["cullender.mapping"]
  end

  # Override prefixes to consider the scoped view.
  # Notice we need to check for the request due to a bug in
  # Action Controller tests that forces _prefixes to be
  # loaded before even having a request object.
  def _prefixes #:nodoc:
    @_prefixes ||= if self.class.scoped_views? && request && cullender_mapping
      super.unshift("#{cullender_mapping.scoped_path}/#{controller_name}")
    else
      super
    end
  end

  hide_action :_prefixes

  protected

  # Checks whether it's a cullender mapped resource or not.
  def assert_is_cullender_resource! #:nodoc:
    unknown_action! <<-MESSAGE unless cullender_mapping
Could not find cullender mapping for path #{request.fullpath.inspect}.
This may happen for two reasons:

1) You forgot to wrap your route inside the scope block. For example:

  cullender_scope :user do
    match "/some/route" => "some_cullender_controller"
  end

2) You are testing a Cullender controller bypassing the router.
   If so, you can explicitly tell Cullender which mapping to use:

   @request.env["cullender.mapping"] = Cullender.mappings[:user]

MESSAGE
  end

  # Returns real navigational formats which are supported by Rails
  def navigational_formats
    @navigational_formats ||= Cullender.navigational_formats.select { |format| Mime::EXTENSION_LOOKUP[format.to_s] }
  end

  def unknown_action!(msg)
    logger.debug "[Cullender] #{msg}" if logger
    raise AbstractController::ActionNotFound, msg
  end

  # Sets the resource creating an instance variable
  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  # Build a cullender resource.
  # Assignment bypasses attribute protection when :unsafe option is passed
  def build_resource(hash = nil, options = {})
    hash ||= resource_params || {}

    if options[:unsafe]
      self.resource = resource_class.new.tap do |resource|
        hash.each do |key, value|
          setter = :"#{key}="
          resource.send(setter, value) if resource.respond_to?(setter)
        end
      end
    else
      self.resource = resource_class.new(hash)
    end
  end
end
