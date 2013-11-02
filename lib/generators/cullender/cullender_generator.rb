require 'generators/cullender/orm_helpers'

module Cullender
	module Generators
		class CullenderGenerator < Rails::Generators::NamedBase
			include Rails::Generators::Migration
			include Cullender::Generators::OrmHelpers			
			source_root File.expand_path('../templates', __FILE__)

			argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
			desc "Generates a model with the given NAME (if one does not exist) with cullender " <<
           "configuration plus a migration file and cullender routes."
			
			class_option :routes, :desc => "Generate routes", :type => :boolean, :default => true           


			def self.next_migration_number(path)
				unless @prev_migration_nr
					@prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
				else
					@prev_migration_nr += 1
				end
				@prev_migration_nr.to_s
			end


			def add_cullender_routes
				cullender_route  = "cullender_for :#{plural_name}"
				cullender_route << %Q(, :class_name => "#{class_name}") if class_name.include?("::")
				cullender_route << %Q(, :skip => :all) unless options.routes?
				route cullender_route
			end


			def copy_cullender_rules_migration
				migration_template "cullender_migration.rb", "db/migrate/create_cullender_tables"
			end

			# def copy_cullender_migration
			# 	if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?(table_name))
			# 		migration_template "migration_existing.rb", "db/migrate/add_cullender_to_#{table_name}"
			# 	else
			# 		migration_template "migration.rb", "db/migrate/create_cullender_for_#{table_name}"
			# 	end
			# end			

			# def inject_cullender_content
			# 	content = model_contents + <<CONTENT
			# 	# Setup accessible (or protected) attributes for your model
			# 	attr_accessible :email, :password, :password_confirmation, :remember_me
			# 	CONTENT

			# 	class_path = if namespaced?
			# 		class_name.to_s.split("::")
			# 	else
			# 		[class_name]
			# 	end

			# 	indent_depth = class_path.size - 1
			# 	content = content.split("\n").map { |line| "  " * indent_depth + line } .join("\n") << "\n"

			# 	inject_into_class(model_path, class_path.last, content) if model_exists?
			# end


			def migration_data
<<RUBY
		t.string :name
		t.boolean :enabled
		t.text :triggers				
RUBY
			end

		end
	end
end
