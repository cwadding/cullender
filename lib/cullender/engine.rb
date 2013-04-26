require 'cullender/engine/routes'

module Cullender
  class Engine < ::Rails::Engine
    # isolate_namespace Cullender
	# config.cullender = Cullender

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load { |app| app.reload_routes! }

    # initializer "devise.url_helpers" do
    #   Cullender.include_helpers(Devise::Controllers)
    # end
  end
end
