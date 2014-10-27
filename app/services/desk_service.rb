class DeskService
  def fetch_filters
    fetch_collection('/api/v2/filters', 'filter') { |entry|
      Filter.new(entry['name'], self_href(entry))
    }
  end

  def fetch_labels
    fetch_collection('/api/v2/labels', 'label') { |entry|
      Label.new(entry['name'], self_href(entry))
    }
  end

  def fetch_filtered_cases(filter)
    fetch_collection("#{filter.url}/cases", 'case') { |entry|
      Case.new(entry['subject'], entry['labels'], self_href(entry))
    }
  end

  def create_label(name)
    data = gateway.post_data(
      "/api/v2/labels",
      name: name
    )

    if data.nil? || data.empty? || data['name'].nil?
      fail "Incorrect response to creating a label"
    end

    fail unless self_class(data) == 'label'

    Label.new(data['name'], self_href(data))
  end

  def assign_label(label, a_case)
    data = gateway.patch_data(
      a_case.url,
      label_action: 'append',
      labels: [label.name]
    )

    if data.nil? || data.empty? || data['subject'].nil?
      fail "Incorrect response to assigning a label"
    end

    fail unless self_class(data) == 'case'

    Case.new(data['subject'], data['labels'], self_href(data))
  end

  private

  def self_href(data)
    data = self_link(data)
    fail unless self_href = data['href']

    self_href
  end

  def self_class(data)
    data = self_link(data)
    fail unless self_class = data['class']

    self_class
  end

  def self_link(data)
    fail unless data
    fail unless links = data['_links']
    fail unless self_link = links['self']

    self_link
  end

  def fetch_collection(url, self_class)
    data = gateway.fetch_records(url)

    if data.nil? || data.empty? || (embedded = data['_embedded']).nil? || (entries = embedded['entries']).nil?
      fail "Failed to find embedded entries in desk service response"
    end

    entries.map { |entry|
      fail unless self_class(entry) == self_class
      yield(entry)
    }
  end

  def gateway
    @gateway ||= DeskGateway.new
  end

  def logger
    @logger ||= Rails.logger
  end

  Filter = Struct.new(:name, :url)
  Case = Struct.new(:subject, :labels, :url)
  Label = Struct.new(:name, :url)
end
