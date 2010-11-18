require 'test_helper'
require 'user_inviter'

class UserInviteTest < ActiveSupport::TestCase

  fixtures :users

  def setup
    # Clean out the fixture stuff.. It breaks the tests..
    UserInvite.delete_all
    ActionMailer::Base.deliveries = []
    @ui = Messaging::UserInviter.new
  end
  
  def test_invalid_email
    assert_nil @ui.invite_user(users(:rob), "adsfasfsd")
    assert_equal ActionMailer::Base.deliveries.length, 0
  end

  def test_valid_email
    ui = @ui.invite_user(users(:rob), "doo@hotmail.com")
    assert_equal ActionMailer::Base.deliveries.length, 1
    assert_equal ui.state, "sent"    
  end
  
  def test_valid_email_but_fails_delivery
    # TODO: hard to test in test mode...
  end
  
  def test_user_invites_friend_twice
    ui = Messaging::UserInviter.new(:max_attempts => 1)
    u = ui.invite_user(users(:rob), "chadrosen@hotmail.com")
    assert_equal u.attempts, 1
    assert_nil ui.invite_user(users(:rob), "chadrosen@hotmail.com")
    assert_equal ActionMailer::Base.deliveries.length, 1
  end
  
  def test_user_invites_friend_of_another_user
    ui = @ui.invite_user(users(:rob), "chadrosen@hotmail.com")
    ui2 = @ui.invite_user(users(:chad), "chadrosen@hotmail.com")
    assert_equal ActionMailer::Base.deliveries.length, 2
  end
  
  def test_user_registers_after_invite
        
    # Invite user and make sure associations are correct
    ui = @ui.invite_user(users(:rob), "foo1@hotmail.com")
    assert_equal ui.invited_by, users(:rob)
    assert_nil ui.registered_user
    
    # Register the user and validate association
    new_user = User.register("foo1@hotmail.com")
    assert_equal new_user.referrer, users(:rob)
        
    # Get the user invite again after registration and validate it's now created..
    ui2 = UserInvite.find_by_email_address("foo1@hotmail.com")
    assert_equal ui2.invited_by, users(:rob)
    assert_equal new_user, ui2.registered_user
  end
  
  def test_user_registers_without_referral
    new_user = User.register("foo1@hotmail.com")
    assert_nil new_user.referrer    
  end
  
  def test_valid_email_array
    assert_not_nil @ui.invite_users(users(:rob), ["foo1@hotmail.com", "foo2@gmail.com"])
    assert_equal ActionMailer::Base.deliveries.length, 2
  end
  
  def test_comma_separated_string
    @ui.invite_users(users(:rob), "foo1@hotmail.com,foo2@gmail.com")
    assert_equal ActionMailer::Base.deliveries.length, 2
  end
  
  def test_newline_separated_string
    @ui.invite_users(users(:rob), "foo1@hotmail.com\nfoo2@gmail.com\n")
    assert_equal ActionMailer::Base.deliveries.length, 2
  end
  
  def test_invite_user_that_already_exists
    # Create the new user
    User.register("foo1@hotmail.com")
    
    assert_nil @ui.invite_user(users(:rob), "foo1@hotmail.com")
  end
  
  def test_user_must_be_active_to_invite
    assert_nil @ui.invite_user(users(:aaron), "foo1@hotmail.com")    
  end

end
