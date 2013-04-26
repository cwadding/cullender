require "active_support/core_ext/object/try"
require "active_support/core_ext/hash/slice"

module ActionDispatch::Routing
  class RouteSet #:nodoc:
    # Ensure Cullender modules are included only after loading routes, because we
    # need cullender_for mappings already declared to create filters and helpers.
    def finalize_with_cullender!
      result = finalize_without_cullender!

      @cullender_finalized ||= begin
        if Cullender.router_name.nil? && defined?(@cullender_finalized) && self != Rails.application.try(:routes)
          warn "[Cullender] We have detected that you are using cullender_for inside engine routes. " \
            "In this case, you probably want to set Cullender.router_name = MOUNT_POINT, where "   \
            "MOUNT_POINT is a symbol representing where this engine will be mounted at. For "   \
            "now Cullender will default the mount point to :main_app. You can explicitly set it"   \
            " to :main_app as well in case you want to keep the current behavior."
        end

        Cullender.regenerate_helpers!
        true
      end

      result
    end
    alias_method_chain :finalize!, :cullender
  end

  class Mapper
    # Includes cullender_for method for routes. This method is responsible to
    # generate all needed routes for cullender, based on what modules you have
    # defined in your model.
    #
    # ==== Examples
    #
    # Let's say you have an User model configured to use authenticatable,
    # confirmable and recoverable modules. After creating this inside your routes:
    #
    #   cullender_for :users
    #
    # This method is going to look inside your User model and create the
    # needed routes:
    #
    #  # Session routes for Authenticatable (default)
    #       new_user_session GET    /users/sign_in                    {:controller=>"cullender/sessions", :action=>"new"}
    #           user_session POST   /users/sign_in                    {:controller=>"cullender/sessions", :action=>"create"}
    #   destroy_user_session DELETE /users/sign_out                   {:controller=>"cullender/sessions", :action=>"destroy"}
    #
    #  # Password routes for Recoverable, if User model has :recoverable configured
    #      new_user_password GET    /users/password/new(.:format)     {:controller=>"cullender/passwords", :action=>"new"}
    #     edit_user_password GET    /users/password/edit(.:format)    {:controller=>"cullender/passwords", :action=>"edit"}
    #          user_password PUT    /users/password(.:format)         {:controller=>"cullender/passwords", :action=>"update"}
    #                        POST   /users/password(.:format)         {:controller=>"cullender/passwords", :action=>"create"}
    #
    #  # Confirmation routes for Confirmable, if User model has :confirmable configured
    #  new_user_confirmation GET    /users/confirmation/new(.:format) {:controller=>"cullender/confirmations", :action=>"new"}
    #      user_confirmation GET    /users/confirmation(.:format)     {:controller=>"cullender/confirmations", :action=>"show"}
    #                        POST   /users/confirmation(.:format)     {:controller=>"cullender/confirmations", :action=>"create"}
    #
    # ==== Options
    #
    # You can configure your routes with some options:
    #
    #  * :class_name => setup a different class to be looked up by cullender, if it cannot be
    #    properly found by the route name.
    #
    #      cullender_for :users, :class_name => 'Account'
    #
    #  * :path => allows you to setup path name that will be used, as rails routes does.
    #    The following route configuration would setup your route as /accounts instead of /users:
    #
    #      cullender_for :users, :path => 'accounts'
    #
    #  * :singular => setup the singular name for the given resource. This is used as the instance variable
    #    name in controller, as the name in routes and the scope given to warden.
    #
    #      cullender_for :users, :singular => :user
    #
    #  * :path_names => configure different path names to overwrite defaults :sign_in, :sign_out, :sign_up,
    #    :password, :confirmation, :unlock.
    #
    #      cullender_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification' }
    #
    #  * :controllers => the controller which should be used. All routes by default points to Cullender controllers.
    #    However, if you want them to point to custom controller, you should do:
    #
    #      cullender_for :users, :controllers => { :sessions => "users/sessions" }
    #
    #  * :failure_app => a rack app which is invoked whenever there is a failure. Strings representing a given
    #    are also allowed as parameter.
    #
    #  * :sign_out_via => the HTTP method(s) accepted for the :sign_out action (default: :get),
    #    if you wish to restrict this to accept only :post or :delete requests you should do:
    #
    #      cullender_for :users, :sign_out_via => [ :post, :delete ]
    #
    #    You need to make sure that your sign_out controls trigger a request with a matching HTTP method.
    #
    #  * :module => the namespace to find controllers (default: "cullender", thus
    #    accessing cullender/sessions, cullender/registrations, and so on). If you want
    #    to namespace all at once, use module:
    #
    #      cullender_for :users, :module => "users"
    #
    #    Notice that whenever you use namespace in the router DSL, it automatically sets the module.
    #    So the following setup:
    #
    #      namespace :publisher do
    #        cullender_for :account
    #      end
    #
    #    Will use publisher/sessions controller instead of cullender/sessions controller. You can revert
    #    this by providing the :module option to cullender_for.
    #
    #    Also pay attention that when you use a namespace it will affect all the helpers and methods for controllers
    #    and views. For example, using the above setup you'll end with following methods:
    #    current_publisher_account, authenticate_publisher_account!, publisher_account_signed_in, etc.
    #
    #  * :skip => tell which controller you want to skip routes from being created:
    #
    #      cullender_for :users, :skip => :sessions
    #
    #  * :only => the opposite of :skip, tell which controllers only to generate routes to:
    #
    #      cullender_for :users, :only => :sessions
    #
    #  * :skip_helpers => skip generating Cullender url helpers like new_session_path(@user).
    #    This is useful to avoid conflicts with previous routes and is false by default.
    #    It accepts true as option, meaning it will skip all the helpers for the controllers
    #    given in :skip but it also accepts specific helpers to be skipped:
    #
    #      cullender_for :users, :skip => [:registrations, :confirmations], :skip_helpers => true
    #      cullender_for :users, :skip_helpers => [:registrations, :confirmations]
    #
    #  * :format => include "(.:format)" in the generated routes? true by default, set to false to disable:
    #
    #      cullender_for :users, :format => false
    #
    #  * :constraints => works the same as Rails' constraints
    #
    #  * :defaults => works the same as Rails' defaults
    #
    # ==== Scoping
    #
    # Following Rails 3 routes DSL, you can nest cullender_for calls inside a scope:
    #
    #   scope "/my" do
    #     cullender_for :users
    #   end
    #
    # However, since Cullender uses the request path to retrieve the current user,
    # this has one caveat: If you are using a dynamic segment, like so ...
    #
    #   scope ":locale" do
    #     cullender_for :users
    #   end
    #
    # you are required to configure default_url_options in your
    # ApplicationController class, so Cullender can pick it:
    #
    #   class ApplicationController < ActionController::Base
    #     def self.default_url_options
    #       { :locale => I18n.locale }
    #     end
    #   end
    #
    # ==== Adding custom actions to override controllers
    #
    # You can pass a block to cullender_for that will add any routes defined in the block to Cullender's
    # list of known actions.  This is important if you add a custom action to a controller that
    # overrides an out of the box Cullender controller.
    # For example:
    #
    #    class RegistrationsController < Cullender::RegistrationsController
    #      def update
    #         # do something different here
    #      end
    #
    #      def deactivate
    #        # not a standard action
    #        # deactivate code here
    #      end
    #    end
    #
    # In order to get Cullender to recognize the deactivate action, your cullender_scope entry should look like this:
    #
    #     cullender_scope :owner do
    #       post "deactivate", :to => "registrations#deactivate", :as => "deactivate_registration"
    #     end
    #
    def cullender_for(*resources)

      @cullender_finalized = false
      options = resources.extract_options!

      options[:as]          ||= @scope[:as]     if @scope[:as].present?
      options[:module]      ||= @scope[:module] if @scope[:module].present?
      options[:path_prefix] ||= @scope[:path]   if @scope[:path].present?
      options[:path_names]    = (@scope[:path_names] || {}).merge(options[:path_names] || {})
      options[:constraints]   = (@scope[:constraints] || {}).merge(options[:constraints] || {})
      options[:defaults]      = (@scope[:defaults] || {}).merge(options[:defaults] || {})
      options[:options]       = @scope[:options] || {}
      options[:options][:format] = false if options[:format] == false

      resources.map!(&:to_sym)

      resources.each do |resource|
        mapping = Cullender.add_mapping(resource, options)
        
        # begin
        #   raise_no_cullender_method_error!(mapping.class_name) unless mapping.to.respond_to?(:cullender)
        # rescue NameError => e
        #   raise unless mapping.class_name == resource.to_s.classify
        #   warn "[WARNING] You provided cullender_for #{resource.inspect} but there is " <<
        #     "no model #{mapping.class_name} defined in your application"
        #   next
        # rescue NoMethodError => e
        #   raise unless e.message.include?("undefined method `cullender'")
        #   raise_no_cullender_method_error!(mapping.class_name)
        # end
        

        routes  = mapping.used_routes

        cullender_scope mapping.name do
          if block_given?
            ActiveSupport::Deprecation.warn "Passing a block to cullender_for is deprecated. " \
              "Please remove the block from cullender_for (only the block, the call to " \
              "cullender_for must still exist) and call cullender_scope :#{mapping.name} do ... end " \
              "with the block instead", caller
            yield
          end
          # debugger
          with_cullender_exclusive_scope mapping.fullpath, mapping.name, options do
            routes.each do |mod| 
                send("cullender_#{mod}", mapping, mapping.controllers)
            end
          end
        end
      end
    end

    # Sets the cullender scope to be used in the controller. If you have custom routes,
    # you are required to call this method (also aliased as :as) in order to specify
    # to which controller it is targetted.
    #
    #   as :user do
    #     get "sign_in", :to => "cullender/sessions#new"
    #   end
    #
    # Notice you cannot have two scopes mapping to the same URL. And remember, if
    # you try to access a cullender controller without specifying a scope, it will
    # raise ActionNotFound error.
    #
    # Also be aware of that 'cullender_scope' and 'as' use the singular form of the
    # noun where other cullender route commands expect the plural form. This would be a
    # good and working example.
    #
    #  cullender_scope :user do
    #    match "/some/route" => "some_cullender_controller"
    #  end
    #  cullender_for :users
    #
    # Notice and be aware of the differences above between :user and :users
    def cullender_scope(scope)
      constraint = lambda do |request|
        request.env["cullender.mapping"] = Cullender.mappings[scope]
        true
      end

      constraints(constraint) do
        yield
      end
    end
    alias :as :cullender_scope

    protected

      def cullender_rule(mapping, controllers) #:nodoc:
        # debugger
        resources :rules, :except => [:edit],
          :path => mapping.path_names[:rule], :controller => controllers[:rules]
      end

      CULLENDER_SCOPE_KEYS = [:as, :path, :module, :constraints, :defaults, :options]

      def with_cullender_exclusive_scope(new_path, new_as, options) #:nodoc:
        old = {}
        CULLENDER_SCOPE_KEYS.each { |k| old[k] = @scope[k] }

        new = { :as => new_as, :path => new_path, :module => nil }
        new.merge!(options.slice(:constraints, :defaults, :options))

        @scope.merge!(new)
        yield
      ensure
        @scope.merge!(old)
      end

      def raise_no_cullender_method_error!(klass) #:nodoc:
        raise "#{klass} does not respond to 'cullender' method. This usually means you haven't " \
          "loaded your ORM file or it's being loaded too late. To fix it, be sure to require 'cullender/orm/YOUR_ORM' " \
          "inside 'config/initializers/cullender.rb' or before your application definition in 'config/application.rb'"
      end
  end
end
