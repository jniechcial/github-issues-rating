require 'pry'
require 'optparse'
require './github_issues_rating'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: start.rb [options]"

  opts.on("--repository=REPOSITORY", "Repository through which you want to rate issues") do |repository|
    options[:repository] = repository
  end

  opts.on("--key=API_KEY", "Your Github API key") do |key|
    options[:api_key] = key
  end

  opts.on("--labels=LABELS", "Comma joined labels you want to filter (e.g. team-messenger,team-inbox)") do |labels|
    options[:labels] = labels
  end

  opts.on("--read-cache", "Specify if issues should be read from cache") do |cache|
    options[:read_cache] = cache
  end

  opts.on("--write-cache", "Specify if fetched issues should be written to cache") do |cache|
    options[:write_cache] = cache
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

GithubIssuesRating.new(
  api_key: options.fetch(:api_key),
  repository: options.fetch(:repository),
  labels: options.fetch(:labels),
  read_cache: options[:read_cache],
  write_cache: options[:write_cache]
).run!
