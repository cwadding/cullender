class CreateCullenderTables < ActiveRecord::Migration
  def change
    create_table :rules do |t|
		t.string :name
		t.boolean :enabled
		t.text :triggers				


      t.timestamps
    end
  end
end