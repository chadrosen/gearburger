require 'test_helper'
require 'vote_processing'

class VoteTest < ActiveSupport::TestCase

  fixtures :contests, :captions, :users

  def test_valid_vote
    valid, reason = Vote.is_vote_valid? contests(:one).id, 1, 1
    assert_equal valid, true
  end
  
  def test_no_browser_cookie
    valid, reason = Vote.is_vote_valid? contests(:one).id, nil, "abcdefg"
    assert_equal valid, false
  end

  def test_no_flash_cookie
    valid, reason = Vote.is_vote_valid? contests(:one).id, 12345, nil
    assert_equal valid, false
  end

  def test_single_user_existing_browser_cookie
    Vote.create_vote contests(:one).id, 1, 1  
    valid, reason = Vote.is_vote_valid? contests(:one).id, 1, 1
    assert_equal valid, false    
  end
  
  def test_validate_empty_cookie_string_still_invalid
    valid, reason = Vote.is_vote_valid?(contests(:one).id, "", "abcdefg")
    assert_equal valid, false
  end
    
  def test_validate_browser_cookie_different_than_flash_cookie
    valid, reason = Vote.is_vote_valid?(contests(:one).id, 1, 2)
    assert_equal valid, false
  end
    
  def test_create_valid_vote
    Vote.create_vote captions(:one).id, 1, 1
    assert_equal captions(:one).vote_count + 1, Caption.find(captions(:one).id).vote_count
  end
  
  def test_create_multiple_valid_votes
    
    v = Vote.create_vote captions(:one).id, 1,1
    assert_equal v.is_valid, true

    v = Vote.create_vote captions(:one).id, 2,2
    assert_equal v.is_valid, true
    
    assert_equal captions(:one).vote_count + 2, Caption.find(captions(:one).id).vote_count
  end

  def test_validate_error_doesnt_increment_count
    v = Vote.create_vote(captions(:one).id, nil, nil)
    assert_equal v.is_valid, false
    
    # Should only have incremented by one
    assert_equal captions(:one).vote_count, Caption.find(captions(:one).id).vote_count
  end
  
  def test_vote_process_different_domains
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("crosen@hotmail.com")
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("crosen@yahoo.com")
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("crosen@msn.com")
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("crosen@foo.bar.crazytown.com")
  end
  
  def test_vote_process_capital_string
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("CROSEN@gmail.com")    
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("Crosen@gmail.com")    
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("cRosen@gmail.com")    
  end
  
  def test_vote_process_invalid_characters
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("crosen1@gmail.com")
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("1crosen1@gmail.com")
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("cro111sen@gmail.com")
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("cro--sen@gmail.com")
    assert_equal VoteProcessing::get_email_root("crosen@gmail.com"), VoteProcessing::get_email_root("cro   sen1@gmail.com")
  end
  
  def test_distance_different_domains_same_string
    assert_equal VoteProcessing::get_email_distance("crosen@gmail.com", "crosen@hotmail.com"), 0
    assert_equal VoteProcessing::get_email_distance("crosen@gmail.com", "crosen@gmail.com"), 0
  end    
end
