class Comment
  attr_accessor :id, :body, :user

  def initialize(id:, body:, user:)
    self.id = id
    self.body = body
    self.user = user
  end

  def is_customer_log?
    # naive check for CS log from customer
    body.include?("**APP ID**:") && body.include?("**Admin ID (who reported issue)**:")
  end
end
