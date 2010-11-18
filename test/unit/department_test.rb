require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase

  fixtures :departments

  def setup
    @md = departments(:mens)
    @wd = departments(:womens)
    @kd = departments(:kids)
  end

  def test_department_general_match
    # Test mens matches
    assert_equal Department.get_value('men', 'blah', 'blah', 'blah'), @md.value
    assert_equal Department.get_value('mens', 'blah', 'blah', 'blah'), @md.value

    # Test womens matches
    assert_equal Department.get_value('women', 'blah', 'blah', 'blah'), @wd.value
    assert_equal Department.get_value('womens', 'blah', 'blah', 'blah'), @wd.value
    
    # Test kids matches
    assert_equal Department.get_value('kid', 'blah', 'blah', 'blah'), @kd.value
    assert_equal Department.get_value('kids', 'blah', 'blah', 'blah'), @kd.value
    assert_equal Department.get_value('boys', 'blah', 'blah', 'blah'), @kd.value
    assert_equal Department.get_value('girls', 'blah', 'blah', 'blah'), @kd.value
  end

  def test_department_category_match
    # Test mens matches
    assert_equal Department.get_value('blah', 'men', 'blah', 'blah'), @md.value

    # Test womens matches
    assert_equal Department.get_value('blah', 'blah', 'womens', 'blah'), @wd.value

    # Test kids matches
    assert_equal Department.get_value('blah', 'blah', 'blah', 'infant'), @kd.value
  end

  def test_department_nonword_nonmatch
    # Test mens matches
    assert_not_equal Department.get_value('mennen', 'blah', 'blah', 'blah'), @md.value

    # Test womens matches
    assert_not_equal Department.get_value('womenly', 'blah', 'blah', 'blah'), @wd.value

    # Test kids matches
    assert_not_equal Department.get_value('infantesimal', 'blah', 'blah', 'blah'), @kd.value    
  end

  def test_department_case_match
    # Test mens matches
    assert_equal Department.get_value('Mens', 'blah', 'blah', 'blah'), @md.value

    # Test womens matches
    assert_equal Department.get_value('WOmen', 'blah', 'blah', 'blah'), @wd.value

    # Test kids matches
    assert_equal Department.get_value('Kids', 'blah', 'blah', 'blah'), @kd.value 
  end

  def test_department_general_nonmatch
    assert_equal Department.get_value('blahblahblah', 'blah', 'blah', 'blah'), nil
  end

end
