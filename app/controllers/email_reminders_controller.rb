class EmailRemindersController < ApplicationController
  before_filter :require_login
  before_filter :require_connected_to_osm
  before_filter :setup_tertiary_menu
  load_and_authorize_resource

  # GET /email_reminders
  # GET /email_reminders.json
  def index
    @email_reminders = EmailReminder.where(['section_id = ?', session[:current_section_id]])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @email_reminders }
    end
  end

  # GET /email_reminders/1
  # GET /email_reminders/1.json
  def show
    @email_reminder = EmailReminder.find(params[:id])
    @tertiary_menu_items.push(['Edit this reminder', edit_email_reminder_path(@email_reminder)])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @email_reminder }
    end
  end

  # GET /email_reminders/new
  # GET /email_reminders/new.json
  def new
    @email_reminder = EmailReminder.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @email_reminder }
    end
  end

  # GET /email_reminders/1/edit
  def edit
    @email_reminder = EmailReminder.find(params[:id])
  end

  # POST /email_reminders
  # POST /email_reminders.json
  def create
    @email_reminder = EmailReminder.new(params[:email_reminder].merge({:user=>current_user, :section_id=>session[:current_section_id]}))

    respond_to do |format|
      if @email_reminder.save
        format.html {
          flash[:instruction] = 'You must now add some items to your reminder.'
          flash[:notice] = 'Email reminder was successfully created.'
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
    @email_reminder = EmailReminder.find(params[:id])

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
    @email_reminder = EmailReminder.find(params[:id])
    @email_reminder.destroy

    respond_to do |format|
      format.html { redirect_to email_reminders_url }
      format.json { head :ok }
    end
  end


  private
  def setup_tertiary_menu
    @tertiary_menu_items = [
      ['List of reminders', email_reminders_path],
      ['New reminder', new_email_reminder_path],
    ]
  end

end