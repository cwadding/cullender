module Cullender
  module Controllers
    module ScopedViews
      extend ActiveSupport::Concern

      module ClassMethods
        def scoped_views?
          defined?(@scoped_views) ? @scoped_views : Cullender.scoped_views
        end

        def scoped_views=(value)
          @scoped_views = value
        end
      end
    end
  end
end