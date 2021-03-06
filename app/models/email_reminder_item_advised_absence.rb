class EmailReminderItemAdvisedAbsence < EmailReminderItem

  validate :configuration_is_valid

  def get_data
    latest = configuration[:the_next_n_weeks].weeks.from_now.to_date
    earliest = Date.current

    api = user.osm_api
    structures = []
    attendances = []
    Osm::Term.get_for_section(user.osm_api, section_id).each do |term|
      if !term.before?(earliest) && !term.after?(latest)
        structures += Osm::Register.get_structure(api, section_id, term)
        attendances += Osm::Register.get_attendance(api, section_id, term)
      end
    end
    attendances.sort!

    dates_to_check = []
    structures.each do |row|
      unless /\A[0-9]{4}-[0-2][0-9]-[0-3][0-9]\Z/.match(row.name).nil?
        date = Date.strptime(row.name, '%Y-%m-%d')
        dates_to_check.push date if (date >= earliest) && (date <= latest)
      end
    end

    data = {}
    dates_to_check.each do |date|
      data[date] = { total_leaders: 0, total_members: 0, absent: [] }
      attendances.each do |row|
        if row.attendance.keys.include?(date)
          leader = row.grouping_id.eql?(-2)
          data[date][leader ? :total_leaders : :total_members] += 1
          if row.attendance[date].eql?(:advised_absent)
            data[date] ||= []
            data[date][:absent].push({
              :first_name => row.first_name,
              :last_name => row.last_name,
              :leader => leader
            })
          end
        end
      end
    end
    return data.empty? ? nil : data
  end


  def get_fake_data
    data = {}
    total_leaders = 2 + rand(4)
    total_members = 4 + rand(20)

    (1 + rand(3)).times do
      people = []
      (1 + rand(3)).times do
        people.push ({
          :first_name => Faker::Name.first_name,
          :last_name => Faker::Name.last_name,
          :leader => (rand(4) < 2),
        })
      end
      date = rand(configuration[:the_next_n_weeks] * 7).days.from_now.to_date
      data[date] = {
        total_leaders: total_leaders,
        total_members: total_members,
        absent: people
      }
    end

    return data
  end

  def self.required_permissions
    [:read, :register]
  end

  def self.configuration_labels
    {
      :the_next_n_weeks => 'For how many weeks?',
    }
  end

  def self.default_configuration
    {
      :the_next_n_weeks => 2,
    }
  end

  def self.configuration_types
    {
      :the_next_n_weeks => :positive_integer,
    }
  end

  def self.human_name
    return 'Advised absences'
  end

  def human_configuration
    "For the next #{configuration[:the_next_n_weeks]} #{"week".pluralize(configuration[:the_next_n_weeks])}."
  end


  private
  def configuration_is_valid
    config = configuration
    unless config[:the_next_n_weeks] > 0
      errors.add('For how many weeks?', 'Must be greater than 0')
      config[:the_next_n_weeks] = self.class.default_configuration[:the_next_n_weeks]
    end
    self.configuration = config
  end

end
