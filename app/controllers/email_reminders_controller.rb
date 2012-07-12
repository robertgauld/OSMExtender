class EmailRemindersController < ApplicationController
  before_filter :require_connected_to_osm, :except => [:index, :show, :preview, :send_email]
  before_filter :except => [:index, :show, :preview, :send_email] do
    forbid_section_type :waiting
  end
  before_filter :setup_tertiary_menu
  load_and_authorize_resource

  # GET /email_reminders
  # GET /email_reminders.json
  def index
    @my_reminders = current_user.email_reminders.order(:section_name)
    @shared_reminders = EmailReminderShare.shared_with(current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @email_reminders }
    end
  end

  # GET /email_reminders/1
  # GET /email_reminders/1.json
  def show
    @email_reminder = EmailReminder.find(params[:id])
    @tertiary_menu_items = nil unless @email_reminder.user == current_user

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @email_reminder }
    end
  end

  # GET /email_reminders/new
  # GET /email_reminders/new.json
  def new
    @email_reminder = current_user.email_reminders.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @email_reminder }
    end
  end

  # GET /email_reminders/1/edit
  def edit
    @email_reminder = current_user.email_reminders.find(params[:id])
    @available_items = get_available_items
  end

  # POST /email_reminders
  # POST /email_reminders.json
  def create
    @email_reminder = current_user.email_reminders.new(params[:email_reminder].merge({:section_id=>current_section.id}))

    respond_to do |format|
      if @email_reminder.save
        format.html {
          flash[:instruction] = 'You must now add some items to your reminder.'
          flash[:notice] = 'Email reminder was successfully created.'
          @available_items = get_available_items
          render action: 'edit'
        }
        format.json { render json: @email_reminder, status: :created, location: @email_reminder }
      else
        format.html { render action: "new" }
        format.json { render json: @email_reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /email_reminders/1
  # PUT /email_reminders/1.json
  def update
    @email_reminder = current_user.email_reminders.find(params[:id])

    respond_to do |format|
      if @email_reminder.update_attributes(params[:email_reminder])
        format.html { redirect_to @email_reminder, notice: 'Email reminder was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @email_reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_reminders/1
  # DELETE /email_reminders/1.json
  def destroy
    @email_reminder = current_user.email_reminders.find(params[:id])
    @email_reminder.destroy

    respond_to do |format|
      format.html { redirect_to email_reminders_url }
      format.json { head :ok }
    end
  end


  def re_order
    params[:email_reminder_item].each_with_index do |id, index|
      current_user.email_reminders.find(params[:id]).items.update_all({position: index+1}, {id: id})
    end
    render nothing: true
  end

  def preview
    @reminder = EmailReminder.find(params[:id])
    @data = @reminder.get_fake_data
    flash[:notice] = 'Fake data has been used in order to ensure that all the selected items have something to show.'
    render "reminder_mailer/reminder_email", :layout => 'mail'
  end

  def send_email
    email_reminder = EmailReminder.find(params[:id])
    unless email_reminder.nil?
      email_reminder.send_email :only_to => current_user, :skip_subscribed_check => true
      redirect_to email_reminders_path, notice: 'Email reminder was successfully sent.'
    else
      redirect_to email_reminders_path, error: 'Email reminder could not be sent.'
    end
  end


  private
  def setup_tertiary_menu
    @tertiary_menu_items = nil
    if current_user.connected_to_osm? && !current_section.waiting?
      @tertiary_menu_items = [
        ['List of reminders', email_reminders_path],
        ['New reminder', new_email_reminder_path],
      ]
    end
  end

  def get_available_items
    items = []
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemBirthday')
      items.push ({:name => 'Birthdays', :type => 'birthday', :as_link => has_osm_permission?(:read, :member)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemEvent')
      items.push ({:name => 'Events', :type => 'event', :as_link => has_osm_permission?(:read, :programme)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemProgramme')
      items.push ({:name => 'Programme', :type => 'programme', :as_link => has_osm_permission?(:read, :programme)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemNotSeen')
      items.push ({:name => 'Member not seen', :type => 'not_seen', :as_link => has_osm_permission?(:read, :register)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemDueBadge')
      items.push ({:name => 'Due badges', :type => 'due_badge', :as_link => has_osm_permission?(:read, :badge)})
    end
    unless @email_reminder.has_an_item_of_type?('EmailReminderItemNotepad')
      items.push ({:name => 'Section Notepad', :type => 'notepad', :as_link => true})
    end
    return items
  end

end
