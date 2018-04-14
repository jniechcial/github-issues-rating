require './issue'

class GithubClient
  def initialize(api_key:, repository:)
    @client = Octokit::Client.new(:access_token => api_key)
    @repository = repository
  end

  def fetch_issues(labels: '')
    puts "Fetch issues page 0"

    issues = fetch_all(
      first_response: @client.issues(@repository, labels: labels, state: 'open').last_response,
      logger: lambda { |index| puts "Fetch issues page #{index}" }
    ) do |issue|
      puts "\tFetch comments for issue #{issue[:number]} page 0"

      comments = fetch_all(
        first_response: issue.rels[:comments].get,
        logger: lambda { |index| puts "\tFetch comments for issue #{issue[:number]} page #{index}" }
      ) do |comment|
        Comment.new(id: comment[:id], body: comment[:body], user: comment[:user][:login])
      end

      Issue.new(
        number: issue[:number],
        url: issue[:url],
        title: issue[:title],
        labels: issue[:labels].map { |label| label[:name] },
        updated_at: issue[:updated_at],
        created_at: issue[:created_at],
        comments: comments
      )
    end

    issues
  end

  private

  def fetch_all(first_response:, logger: lambda { |index| "Fetching page #{index}" })
    records = []
    last_response = first_response
    index = 1

    loop do
      if block_given?
        records = records + last_response.data.map do |record|
          yield record
        end
      else
        records = records + last_response.data
      end

      if last_response.rels[:next]
        logger.call(index)
        index = index + 1
        last_response = last_response.rels[:next].get
      else
        break
      end
    end

    records
  end
end
