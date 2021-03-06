class IssueRater
  WINDOW_TIME_DIFFERENCE = 365
  WINDOW_LOW_RESULT = 0.2
  MANUAL_BUMPS_PATH = './manual_bumps.bak'

  def self.manual_bumps
    return @manual_bumps if @manual_bumps
    @manual_bumps = {}

    CSV.foreach(MANUAL_BUMPS_PATH) do |row|
      issue_number, bump = row[0].split(' | ')
      @manual_bumps[issue_number] = bump.to_f
    end

    @manual_bumps
  end

  def initialize(issue:)
    @issue = issue
  end

  def calculate_rating
    (rate_customer_logs_count + rate_system_priority + rate_vip_customer) * time_window_multiplier + manual_bump
  end

  private

  def manual_bump
    IssueRater.manual_bumps[@issue.number] || 0
  end

  def rate_customer_logs_count
    @issue.comments.select { |comment| comment.is_customer_log? }.length
  end

  def rate_system_priority
    case(@issue.system_priority)
    when 'P1'
      50
    when 'P2'
      25
    when 'P3'
      5
    else
      0
    end
  end

  def rate_vip_customer
    @issue.is_vip_customer? ? 50 : 0
  end

  def time_window_multiplier
    a = (1 - WINDOW_LOW_RESULT) / WINDOW_TIME_DIFFERENCE
    b = 1

    if @issue.updated_at < (Date.today - WINDOW_TIME_DIFFERENCE)
      WINDOW_LOW_RESULT
    else
      a * (@issue.updated_at - Date.today) + b
    end
  end
end
