class Issue
  attr_accessor :url, :created_at, :updated_at, :labels, :title, :number, :comments

  def initialize(number:, url:, title:, labels:, updated_at:, created_at:, comments: [])
    self.number = number
    self.url = url
    self.title = title
    self.labels = labels
    self.updated_at = Date.parse(updated_at)
    self.created_at = Date.parse(created_at)
    self.comments = comments
  end

  def system_priority
    return 'P1' if labels.include?('P1')
    return 'P2' if labels.include?('P2')
    return 'P3' if labels.include?('P3')
  end

  def is_vip_customer?
    labels.include?('VIP Customer')
  end
end
