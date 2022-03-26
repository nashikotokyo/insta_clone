class ChangeFolloweridAndFollowedidOfRelationships < ActiveRecord::Migration[5.2]
  def up
    change_column :relationships, :follower_id, :bigint, null: false
    change_column :relationships, :followed_id, :bigint, null: false
  end

  def down
    change_column :relationships, :follower_id, :integer, null: false
    change_column :relationships, :followed_id, :integer, null: false
  end
end
