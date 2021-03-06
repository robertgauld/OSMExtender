class EmailReminderItemDueBadge < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    api = user.osm_api
    due_badges = Osm::Badges.get_due_badges(api, section_id)

    return nil if due_badges.empty?

    return due_badges
  end


  def get_fake_data
    badge_names = {}
    by_member = {}
    member_names = {}
    badge_stock = {}
    
    badges_generated = (1 + rand(3))

    (1 + rand(8)).times do |member_id|
      member_names[member_id] = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
      by_member[member_id] ||= []
      (1..badges_generated).each do |badge_num|
        badge_name = "#{badge_num.ordinalize} badge"
        badge_tag = "#{badge_num}_1"
        badge_names[badge_tag] = badge_name
        by_member[member_id].push(badge_tag) if (rand(10) % 3) >= 1
      end
    end

    badge_names.each_key do |badge_tag|
      badge_stock[badge_tag] = rand(10)
    end

    by_member = by_member.select{ |k,v| !v.empty? }

    return Osm::Badges::DueBadges.new(:by_member => by_member, :badge_names => badge_names, :member_names => member_names, :badge_stock => badge_stock)
  end


  def self.required_permissions
    [:read, :badge]
  end

  def self.configuration_labels
    {
      :show_stock => 'Show stock level of badges?',
    }
  end

  def self.default_configuration
    {
      :show_stock => false
    }
  end

  def self.configuration_types
    {
      :show_stock => :boolean,
    }
  end

  def self.human_name
    return 'Due badges'
  end

  def human_configuration
    "#{configuration[:show_stock] ? 'With' : 'Without'} badge stock levels."
  end


  private
  def configuration_is_valid
    config = configuration
    unless [true, false].include?(config[:show_stock])
      errors.add('Show stock level of badges?', 'Invalid option')
      config[:show_stock] = self.class.default_configuration[:show_stock]
    end
    self.configuration = config
  end

end
