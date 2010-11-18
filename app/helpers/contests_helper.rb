module ContestsHelper

  def ordinalize(number)
    return ActiveSupport::Inflector.ordinalize(number)
  end

end
