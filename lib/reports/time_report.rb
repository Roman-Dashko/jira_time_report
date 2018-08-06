require "active_support/all"

module Reports
  module TimeReport
    extend ActiveSupport::NumberHelper

    class << self
      def create_form_params
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

      def projects
        # url = url({'projects' => 'all'}, false)
        # uri = URI("#{current_jwt_auth.api_base_url}#{url}")
        # http = Net::HTTP.new(uri.host, uri.port)
        # http.use_ssl = true
        # request = Net::HTTP::Get.new(uri.request_uri)
        # request.initialize_http_header({'Authorization' => "JWT #{jwt_token(:get, url)}"})
        # response = http.request(request)


        response = HTTParty.get(create_url({'projects' => 'all'}))
        response.parsed_response.collect {|h| ["#{h['name']} (#{h['key']})", h['id']]}
      end

      def issue_types
        response = HTTParty.get(create_url({'issue_types' => 'all'}))
        response.parsed_response.collect {|h| [h['name']]}.uniq
      end

      def assignees
#       url = 'https://romand.atlassian.net/rest/api/2/user/search?username=%'
# # The key of the add-on as defined in the add-on description
#       issuer = 'app-moc-report'
#       http_method = 'get' # The HTTP Method (GET, POST, etc) of the API call
#       shared_secret = 'WSTwGKD5ClZ66oT7DLSB3rVTv+LyZdYSs4U+yUOyCTjpM5dZim2jrIgSTRH6pdwviMtVb2EV1ebpA+jaVbOkNw' # "sharedSecret", returned when the add-on is installed.
#       base_url = 'https://romand.atlassian.net'
#       claim = Atlassian::Jwt.build_claims(issuer,url,http_method,base_url)
#       jwt = JWT.encode(claim,shared_secret)


# url = url({'assignees' => 'all'}, false)
# uri = URI(url)
# uri = URI("#{url}?jwt=#{jwt}")
#
# http = Net::HTTP.new(uri.host, uri.port)
# http.use_ssl = true
# request = Net::HTTP::Get.new(uri.request_uri)
# # request.initialize_http_header({'Authorization' => "JWT #{jwt}"})
# response = http.request(request)

# Query String
#       http = Net::HTTP.new(uri.host, uri.port)
#       request = Net::HTTP::Get.new(uri.request_uri)
#       response = http.request(request)

# response
        response = HTTParty.get(create_url({'assignees' => 'all'}))
        response.parsed_response.collect {|h| [h['name'], h['emailAddress']]}.select {|ar| !ar[0].include?("addon_")}
      end

      def statuses
        response = HTTParty.get(create_url({'statuses' => 'all'}))
        response.parsed_response.collect {|h| [h['name'], h['id']]}
      end

      def grouping
        ['project', 'issue', 'issue type', 'assignee', 'status']
      end

      def detailing
        %w(day week month year)
      end

      def create_url(params, jwt = true)
        url = "http://testtost2018:zzz123456789@romand.atlassian.net/rest/api/2/"
        # url = '/rest/api/2/'
        # url = "http://romand.atlassian.net/rest/api/2/"

        if params.key?('commit')
          url += URI.encode("search?fields=project,summary,issuetype,assignee,status,worklog&jql=worklogDate >= #{params['from']} AND worklogDate <= #{params['to']}")

          if params.key?('projects')
            url += URI.encode(" AND project in (#{params['projects'].split.map {|el| "'#{el}'"}.join(',')})")
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
            url += 'user/search?username=%'
          end

          if params['statuses'] == 'all'
            url += 'status'
          end
        end
        url
        # jwt ? rest_api_url(:get, url) : url
      end

      def group_data(data, params)
        grouped_data = data.group_by {|hash| hash.values_at(*params).join ":"}.values.map do |grouped|
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

        grouped_data.sort_by {|hash| hash.values_at(*params).join ":"}
      end

      def detail_data(grouped_data, param)
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
        grouped_data.each {|hash| hash[param] = hash['worklogs'].group_by {|b| b["date"].to_date.strftime(date_formatting)}.collect {|key, value| {"date" => key, "seconds" => value.sum {|d| d["seconds"].to_i}}}.sort_by {|hash| hash['date']}}
        grouped_data.each {|hash| hash['total_time'] = hash['worklogs'].map {|s| s['seconds']}.reduce(0, :+)}
      end

      def create_data
        url = create_url(@params, false)
        # url = rest_api_url(:get, url)


        # uri = URI("#{current_jwt_auth.api_base_url}#{url}")
        # http = Net::HTTP.new(uri.host, uri.port)
        # http.use_ssl = true
        # request = Net::HTTP::Get.new(uri.request_uri)
        # request.initialize_http_header({'Authorization' => "JWT #{jwt_token(:get, url)}"})
        # response = http.request(request)


        # response = HTTParty.send(:get, url, {
        #   # body: data ? data.to_json : nil,
        #   headers: {'Content-Type' => 'application/json', 'Authorization' => "JWT #{jwt_token(:get, url)}"}
        # })

        response = HTTParty.get(url)
        return nil if response.nil? || response.parsed_response['issues'].nil?

        data = []
        response.parsed_response['issues'].each do |issue|
          issue_data = {}
          issue_data['project'] = issue['fields']['project']['key'] + ' ::: ' + issue['fields']['project']['name']
          issue_data['issue'] = issue['key'] + ' ::: ' + issue['fields']['summary']
          issue_data['issue type'] = issue['fields']['issuetype']['name']
          issue_data['assignee'] = issue['fields']['assignee']['name']
          issue_data['status'] = issue['fields']['status']['name']

          worklogs_data = []
          issue['fields']['worklog']['worklogs'].each do |worklog|
            next unless Date.parse(worklog['started']).between?(Date.parse(@params['from']), Date.parse(@params['to']))
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

        processed_data = []
        group_by = []
        @params['group_by'].each do |grouping|
          group_by << grouping
          grouped_data = group_data(data, group_by)
          processed_data << detail_data(grouped_data, @params['detail_by'])
        end
        processed_data
      end

      def create_periods(data, param)
        periods = data.first.map {|hash| hash[param]}.flatten.group_by {|h| h['date']}
                    .map {|k, v| {'date' => k, 'seconds' => v.map {|h1| h1['seconds']}.inject(:+)}}.sort_by {|h2| h2['date']}
        periods << {'total_time' => data.first.map {|hash| hash['total_time']}.inject(:+)}
      end

      def create_report_header
        header = {}
        @params['group_by'].each do |grouping|
          header[grouping] = 'grouping'
        end
        @periods.each do |period, amount|
          header[period['date']] = 'period' if period['date']
        end
        header['Total Time'] = 'total'
        header
      end

      def create_report_body(data)
        body = []
        data.last.each do |data_row|
          grouping_number = data.size
          if grouping_number > 1
            i = 1
            condition = "h[@params['group_by'][0]] == data_row[@params['group_by'][0]]"
            while i < data.size
              condition_lambda = eval("->(h) {#{condition}}")
              data_row_grouping = data[i - 1].detect(&condition_lambda)
              if data_row_grouping.present? && !data_row_grouping['placed']
                body << create_body_row(data_row_grouping, i)
              end
              data_row_grouping['placed'] = true
              condition += " && h[@params['group_by'][#{i}]] == data_row[@params['group_by'][#{i}]]"
              i += 1
            end
          end
          body << create_body_row(data_row, grouping_number)
        end
        body
      end

      def create_body_row(data_row, grouping_number)
        report_body_row = []
        @params['group_by'].each_with_index do |grouping, index|
          value = data_row[grouping] && (index + 1 == grouping_number) ? data_row[grouping] : ''
          report_body_row << value
        end
        @periods.each do |period|
          if period['date']
            period_record = data_row[@params['detail_by']].find {|h| h['date'] == period['date']}
            value = period_record.present? ? period_record['seconds'] : ''
            report_body_row << to_hours(value)
          end
        end
        report_body_row << to_hours(data_row['total_time'])
        report_body_row
      end

      def create_report_footer
        footer = []
        @params['group_by'].each_with_index do |grouping, index|
          value = index == 0 ? 'Total Time' : ''
          footer << value
        end
        @periods.each do |period|
          footer << to_hours(period['seconds']) if period['date']
        end
        footer << to_hours(@periods.last['total_time'])
        footer
      end

      def create_report(params)
        @params = params
        data = create_data
        @periods = create_periods(data, @params['detail_by'])

        report = {}
        report['header'] = create_report_header
        report['body'] = create_report_body(data)
        report['footer'] = create_report_footer
        report
      end

      def to_hours(seconds)
        seconds.to_i > 0 ? number_to_rounded(seconds.to_f / 3600, precision: 2) : ''
      end

      def to_csv(report)

        column_labels = []

        CSV.generate(headers: true) do |csv|
          report['header'].each_key do |key|
            column_labels << key
          end
          csv << column_labels
          report['body'].each do |body_row|
            csv << body_row
          end
          csv << report['footer']
        end
      end
    end
  end
end


