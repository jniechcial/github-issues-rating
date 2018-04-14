require 'pry'
require 'octokit'
require './github_client'
require './cache_client'
require './issue_rater'

class GithubIssuesRating
  CACHE_DIRECTORY_PATH = '.'

  def initialize(api_key:, repository:, labels:, read_cache: false, write_cache: false)
    @labels = labels
    @read_cache = read_cache
    @write_cache = write_cache
    @api_key = api_key
    @repository = repository
  end

  def run!
    issues = if @read_cache
               read_issues_from_cache
             else
               fetch_fresh_issues
             end

    write_issues_to_cache(issues) if @write_cache && !@read_cache

    rated = rate_issues(issues)

    rated.each do |issue|
      puts sprintf("%3.2f | %s", issue[:rating], issue[:issue].url)
    end
  end

  private

  def read_issues_from_cache
    CacheClient.new(cache_directory_path: CACHE_DIRECTORY_PATH).read_issues!
  end

  def write_issues_to_cache(issues)
    CacheClient.new(cache_directory_path: CACHE_DIRECTORY_PATH).write_issues!(issues)
  end

  def fetch_fresh_issues
    GithubClient.new(api_key: @api_key, repository: @repository).fetch_issues(labels: @labels)
  end

  def rate_issues(issues)
    rated = issues.map { |issue| { rating: IssueRater.new(issue: issue).calculate_rating, issue: issue } }
    rated.sort { |a, b| b[:rating] - a[:rating] }
  end
end
