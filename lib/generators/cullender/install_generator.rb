module Cullender
	module Generators
		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			desc "Creates a Cullender initializer and copy locale files to your application."


			def create_initializer_file
				template "cullender.rb", "config/initializers/cullender.rb"
			end

			def copy_locale
				copy_file "../../../../config/locales/en.yml", "config/locales/cullender.en.yml"
			end
		end
	end
end
