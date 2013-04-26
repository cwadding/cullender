class CreateCullenderTables < ActiveRecord::Migration
  def change
    create_table :rules do |t|
<%= migration_data -%>

<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>

      t.timestamps
    end
  end
end