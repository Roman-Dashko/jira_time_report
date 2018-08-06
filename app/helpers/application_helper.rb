module ApplicationHelper

  def style(report_part, type)
    if report_part == 'body'
      if type == 'grouping'
        'string'
      elsif type == 'period'
        'number'
      else
        'bold_number'
      end
    else
      type == 'grouping' ? 'string' : 'number'
    end
  end

  def data_type(i)
    @report['header'][@report['header'].keys[i]]
  end
end
