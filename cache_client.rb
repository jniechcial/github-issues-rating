require 'pry'
require 'csv'
require './issue'
require './comment'

class CacheClient
  def initialize(cache_directory_path:)
    @cache_directory_path = cache_directory_path
  end

  def read_issues!
    issues = []
    issues_index = {}

    CSV.foreach(@cache_directory_path + '/issues.bak') do |row|
      issue = Issue.new(
        number: row[0],
        url: row[1],
        title: row[2],
        labels: row[3].split(','),
        updated_at: row[4],
        created_at: row[5]
      )

      issues << issue
      issues_index[issue.number] = issue
    end

    CSV.foreach(@cache_directory_path + '/comments.bak') do |row|
      comment = Comment.new(
        id: row[0],
        body: row[2],
        user: row[3]
      )

      issue = issues_index[row[1]]
      issue.comments << comment
    end

    issues
  end

  def write_issues!(issues)
    CSV.open(@cache_directory_path + '/issues.bak', "w+") do |csv|
      issues.each do |issue|
        csv << [issue.number, issue.url, issue.title, issue.labels.join(','), issue.updated_at, issue.created_at]
      end
    end

    CSV.open(@cache_directory_path + '/comments.bak', "w+") do |csv|
      issues.each do |issue|
        issue.comments.each do |comment|
          csv << [comment.id, issue.number, comment.body.gsub("\r\n", "\\r\\n"), comment.user]
        end
      end
    end
  end
end
