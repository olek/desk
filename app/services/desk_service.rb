class DeskService
  def fetch_filters
    gateway.fetch_records("/api/v2/filters")['_embedded']['entries'] or
      raise "Failed to find 'entries' in desk service response"
  end

  private

  def gateway
    @gateway ||= DeskGateway.new
  end

  def logger
    @logger ||= Rails.logger
  end
end
