class MakeDefultPriceToBounty < ActiveRecord::Migration
  def change
  	change_column :users, :balance, :float, :default => 0.0
  end
end
