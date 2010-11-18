class AddReferralUrl < ActiveRecord::Migration
  def self.up
    add_column(:users, :referral_url, :string, :null => true)
    remove_column(:users, :abingo_identity)
  end

  def self.down
    add_column(:users, :abingo_identity, :integer, :null => true)
    remove_column(:users, :referral_url)
  end
end
