class EmailReminderItemProgrammesController < EmailReminderItemsController
  before_filter { require_osm_permission :read, :member }

  def model
    return EmailReminderItemProgramme
  end

end
