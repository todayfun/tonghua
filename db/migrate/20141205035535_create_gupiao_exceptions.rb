class CreateGupiaoExceptions < ActiveRecord::Migration
  def change
    create_table :gupiao_exceptions do |t|
      t.string :code
      t.string :exception
      t.date :deal_on
      t.string :sig      
    end
    add_index :gupiao_exceptions, :code
    add_index :gupiao_exceptions, :sig
  end
end
