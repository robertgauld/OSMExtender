Given /^"([^"]*)" has a reminder email for section (\d*) on "([^"]*)"$/ do |email_address, section_id, day|
  day = {
    'Sunday' => 0,
    'Monday' => 1,
    'Tuesday' => 2,
    'Wednesday' => 3,
    'Thursday' => 4,
    'Friday' => 5,
    'Saturday' => 6,
  }[day]
  user = User.find_by_email_address(email_address)
  er = EmailReminder.create :user => user, :send_on => day, :section_id => section_id.to_i
end

Given /^"([^"]*)" has an? (.*) item in (?:her|his|their) "(.*)" email reminder for section (\d*)$/ do |email_address, type, day, section_id|
  section_id = section_id.to_i
  types = {
    'birthday' => EmailReminderItemBirthday,
    'event' => EmailReminderItemEvent,
    'programme' => EmailReminderItemProgramme,
    'not seen' => EmailReminderItemNotSeen,
    'due badge' => EmailReminderItemDueBadge,
  }
  user = User.find_by_email_address(email_address)
  er = nil
  user.email_reminders.each do |reminder|
    if (reminder.section_id == section_id) && %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}[reminder.send_on].eql?(day)
      er = reminder
    end
  end
  types[type].create :email_reminder => er
end

Given /^"([^"]*)" has a reminder email for section (\d*) on "([^"]*)" with all items$/ do |email_address, section_id, day|
  step "\"#{email_address}\" has a reminder email for section #{section_id} on \"#{day}\""
  step "\"#{email_address}\" has a birthday item in her \"#{day}\" email reminder for section #{section_id}"
  step "\"#{email_address}\" has an event item in her \"#{day}\" email reminder for section #{section_id}"
  step "\"#{email_address}\" has a programme item in her \"#{day}\" email reminder for section #{section_id}"
  step "\"#{email_address}\" has a not seen item in her \"#{day}\" email reminder for section #{section_id}"
  step "\"#{email_address}\" has a due badge item in her \"#{day}\" email reminder for section #{section_id}"
step "\"#{email_address}\" should have 1 email reminder"
end


When /^"([^"]*)"'s reminder email for section (\d*) on "([^"]*)" is sent$/ do |email_address, section_id, day|
  section_id = section_id.to_i
  user = User.find_by_email_address(email_address)
  user.email_reminders.each do |reminder|
    if (reminder.section_id == section_id) && %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}[reminder.send_on].eql?(day)
      reminder.send_email
    end
  end
end

When /^I preview the ([^"]*) email reminder for section (\d*) as ([^"]*)$/ do |day, section_id, format|
  day = {
    'Sunday' => 0,
    'Monday' => 1,
    'Tuesday' => 2,
    'Wednesday' => 3,
    'Thursday' => 4,
    'Friday' => 5,
    'Saturday' => 6,
  }[day]
  section_id = section_id.to_i
  er = EmailReminder.find_by_section_id_and_send_on(section_id, day)
  visit preview_email_reminder_path(er.id, format)
end


Then /^"([^"]*)" should have (\d+) email reminder$/ do |email_address, count|
  user = User.find_by_email_address(email_address)
  user.email_reminders.count.should == count.to_i
end
