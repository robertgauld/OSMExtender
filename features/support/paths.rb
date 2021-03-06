module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'

    when /^the list of (.*)$/
      self.send("#{$1.downcase}_path".to_sym)

    when /^the page for ([^\d]*) (\d+)$/
      self.send("#{$1.downcase}_path".to_sym, $2.to_i)

    when /^the page for ([^\d]*) (\d+) (\d+)$/
      self.send("#{$1.downcase}_path".to_sym, $2.to_i, $3.to_i)

    when /^the osm_flexi_records_for_section (\d+) page$/
      "/osm_flexi_records/#{$1}"

    when /^reset_password token="([^"]*)"$/
      "/reset_password/#{$1}"
    when /^activate_account token="([^"]*)"$/
      "/activate_account/#{$1}"
    when /^edit the user "([^"]*)"$/
      edit_user_path(User.find_by_email_address($1))
    when /^reset the password for "([^"]*)"$/
      reset_password_user_path(User.find_by_email_address($1))
    when /^resend the activation email for "([^"]*)"$/
      resend_activation_user_path(User.find_by_email_address($1))
    when /^([^"]*) "([^"]*)"'s email reminder$/
      method = ($1.eql?('show')) ? '' : "/#{$1}"
      reminder = User.find_by_email_address!($2).email_reminders.first
      "/email_reminders/#{reminder.id}#{method}"
    when /^the edit shared event "([^"]*)" page$/
      edit_shared_event_path(SharedEvent.find_by_name($1))
    when /^the attend shared event "([^"]*)" page$/
      new_shared_event_attendance_url({:se_id => SharedEvent.find_by_name($1).id})
    when /^"(.+)"$/
      $1

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
