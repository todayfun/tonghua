class CreateGupiaos < ActiveRecord::Migration
  def change
    create_table :gupiaos do |t|
      t.string :name
      t.string :code
      t.string :trend
      t.string :stamp
      t.string :status
      t.string :judge

      t.timestamps
    end
  end
end
