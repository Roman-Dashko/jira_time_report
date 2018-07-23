module ApplicationHelper
  def to_hours(seconds)
    seconds.to_i > 0 ? number_with_precision(seconds.to_f/3600, precision: 2) : ''
  end
end
