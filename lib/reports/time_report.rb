module Reports
  module TimeReport

    def self.form_params
      form_params = {}
      form_params['from'] = Date.new(2018, 5, 1)
      form_params['to'] = Date.new(2018, 5, 31)

      form_params['projects'] = projects
      form_params['issue_types'] = issue_types
      form_params['assignees'] = assignees
      form_params['statuses'] = statuses

      form_params['group_by'] = grouping
      form_params['detail_by'] = detailing

      form_params
    end

    def self.projects
      response = HTTParty.get(create_url({'projects' => 'all'}))
      response.parsed_response.collect {|h| ["#{h['name']} (#{h['key']})", h['id']]}
    end

    def self.issue_types
      response = HTTParty.get(create_url({'issue_types' => 'all'}))
      response.parsed_response.collect {|h| [h['name']]}.uniq
    end

    def self.assignees
      response = HTTParty.get(create_url({'assignees' => 'all'}))
      response.parsed_response.collect {|h| [h['name'], h['emailAddress']]}.select {|ar| !ar[0].include?("addon_")}
    end

    def self.statuses
      response = HTTParty.get(create_url({'statuses' => 'all'}))
      response.parsed_response.collect {|h| [h['name'], h['id']]}
    end

    def self.grouping
      ['project', 'issue', 'type', 'assignee', 'status']
    end

    def self.detailing
      %w(day week month year)
    end

    def self.create_url(params)
      url = "http://testtost2018:zzz123456789@romand.atlassian.net/rest/api/2/"

      if params.key?('commit')
        url += URI.encode("search?fields=project,summary,issuetype,assignee,status,worklog&jql=worklogDate >= #{params['from']} AND worklogDate <= #{params['to']}")

        if params.key?('projects')
          url += URI.encode(" AND project in (#{params['projects'].map {|el| "'#{el}'"}.join(',')})")
        end
        if params.key?('issue_types')
          url += URI.encode(" AND issuetype in (#{params['issue_types'].map {|el| "'#{el}'"}.join(',')})")
        end
        if params.key?('assignees')
          url += URI.encode(" AND assignee in (#{params['assignees'].map {|el| "'#{el}'"}.join(',')})")
        end
        if params.key?('statuses')
          url += URI.encode(" AND status in (#{params['statuses'].map {|el| "'#{el}'"}.join(',')})")
        end

      else
        if params['projects'] == 'all'
          url += 'project'
        end

        if params['issue_types'] == 'all'
          url += 'issuetype'
        end

        if params['assignees'] == 'all'
          url += '/user/search?username=%'
        end

        if params['statuses'] == 'all'
          url += 'status'
        end
      end

      url

    end

    def self.group_data(data, params)
      data = data.group_by {|hash| hash.values_at(*params).join ":"}.values.map do |grouped|
        grouped.inject do |merged, n|
          merged.merge(n) do |key, v1, v2|
            if params.include?(key)
              v1
            elsif key == 'worklogs'
              v1 + v2
            end
          end
        end
      end

      data.sort_by {|hash| hash.values_at(*params).join ":"}
    end

    def self.detail_data(data, param)
      date_formatting = case param
                          when 'day'
                            "%Y-%m-%d"
                          when 'week'
                            "%Y-%W"
                          when 'month'
                            "%Y-%m"
                          else
                            "%Y"
                        end
      data.each {|hash| hash[param] = hash['worklogs'].group_by {|b| b["date"].to_date.strftime(date_formatting)}.collect {|key, value| {"date" => key, "seconds" => value.sum {|d| d["seconds"].to_i}}}.sort_by {|hash| hash['date']}}
      data.each {|hash| hash['total_time'] = hash['worklogs'].map {|s| s['seconds']}.reduce(0, :+)}
    end

    def self.data(params = {})
      url = create_url(params)

      response = HTTParty.get(url)
      return if response.nil?

      data = []
      response.parsed_response['issues'].each do |issue|
        issue_data = {}
        issue_data['project'] = issue['fields']['project']['name']
        issue_data['issue'] = issue['key'] + ': ' + issue['fields']['summary']
        issue_data['type'] = issue['fields']['issuetype']['name']
        issue_data['assignee'] = issue['fields']['assignee']['name']
        issue_data['status'] = issue['fields']['status']['name']

        worklogs_data = []
        issue['fields']['worklog']['worklogs'].each do |worklog|
          next unless Date.parse(worklog['started']).between?(Date.parse(params['from']), Date.parse(params['to']))
          worklog_data = {}
          worklog_data['date'] = Date.parse(worklog['started'])
          worklog_data['seconds'] = worklog['timeSpentSeconds']
          # worklog_data[Date.parse(worklog['started'])] = worklog['timeSpentSeconds']
          worklogs_data << worklog_data
        end
        issue_data['worklogs'] = worklogs_data
        issue_data['rendered'] = false
        data << issue_data
      end

      report = []
      group_by = []
      params['group_by'].each do |grouping|
        group_by << grouping
        grouped_data = group_data(data, group_by)
        report << detail_data(grouped_data, params['detail_by'])
      end
      report
    end

    def self.periods(data, param)
      periods = data.last.map {|hash| hash[param]}.flatten.group_by {|h| h['date']}
                  .map {|k, v| {'date' => k, 'seconds' => v.map {|h1| h1['seconds']}.inject(:+)}}.sort_by {|h2| h2['date']}
      periods << {'total_time' => data.first.map {|hash| hash['total_time']}.inject(:+)}
    end
  end
end


