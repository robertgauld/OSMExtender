class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login
  helper_method :current_section, :current_announcements, :has_osm_permission?, :user_has_osm_permission?,
                :api_has_osm_permission?, :get_section_names, :get_grouping_name,
                :get_current_section_terms, :get_current_term_id,
                :osm_user_permission_human_friendly, :osm_api_permission_human_friendly


  unless Rails.configuration.consider_all_requests_local
    rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from AbstractController::ActionNotFound, :with => :render_not_found
  end


  private
  def not_authenticated
    flash[:error] = 'You must be signed in to access this resource.'
    redirect_to signin_path
  end


  # Ensure the user has connected to OSM
  # if not redirect them to the relevant page and set an instruction flash
  def require_connected_to_osm
    unless current_user.connected_to_osm?
      # Send user to the connect to OSM page
      flash[:instruction] = 'You must connect to your OSM account first.'
      redirect_to(current_user ? connect_to_osm_path : signin_path)
    end
  end


  # Get a human friendly description of how a permission is set for a user in OSM
  def osm_user_permission_human_friendly(permission_on, user=current_user, section=current_section)
    permissions = user.osm_api.get_user_permissions
    permissions = permissions[section.to_i] || {}
    permissions = (permissions[permission_on] || [])
    return 'Administer' if permissions.include?(:administer)
    return 'Read and Write' if permissions.include?(:write)
    return 'Read' if permissions.include?(:read)
    return 'No permissions'
  end

  # Get a human friendly description of how a permission is set for the api in OSM
  def osm_api_permission_human_friendly(permission_on, user=current_user, section=current_section)
    permissions = Osm::ApiAccess.get_ours(user.osm_api, section.to_i).permissions
    permissions = permissions[permission_on] || []
    return 'Administer' if permissions.include?(:administer)
    return 'Read and Write' if permissions.include?(:write)
    return 'Read' if permissions.include?(:read)
    return 'No permissions'
  end

  # Ensure the user has a given OSM permission
  # if not redirect them to the osm permissions page and set an instruction flash
  # @param permission_to the action which is being checked (:read or :write)
  # @param permission_on the object type which is being checked (:member, :register ...), this can be an array in which case the user must be able to perform the action to all objects
  def require_osm_permission(permission_to, permission_on, user=current_user, section=current_section)
    unless has_osm_permission?(permission_to, permission_on, user, section)
      # Send user to the osm permissions page
      flash[:error] = 'You do not have the correct OSM permissions to do that.'
      redirect_back_or_to(current_user ? osm_permissions_path : signin_path)
    end
  end

  # Check if the user and API have a given OSM permission
  # @param permission_to the action which is being checked (:read or :write), this can be an array in which case the user must be able to perform all actions to the object
  # @param permission_on the object type which is being checked (:member, :register ...), this can be an array in which case the user must be able to perform the action to all objects
  def has_osm_permission?(permission_to, permission_on, user=current_user, section=current_section)
    user_can = user_has_osm_permission?(permission_to, permission_on, user, section)
    api_can = api_has_osm_permission?(permission_to, permission_on, user, section)
    return user_can && api_can
  end

  # Check if the user has a given OSM permission
  def user_has_osm_permission?(permission_to, permission_on, user=current_user, section=current_section)
    permissions = user.osm_api.get_user_permissions
    permissions = permissions[section.to_i] || {}
    [*permission_on].each do |on|
      [*permission_to].each do |to|
        unless (permissions[on] || []).include?(to)
          return false
        end
      end
    end
    return true
  end

  # Check if the API has a given OSM permission
  def api_has_osm_permission?(permission_to, permission_on, user=current_user, section=current_section)
    permissions = Osm::ApiAccess.get_ours(user.osm_api, section.to_i).permissions
    [*permission_on].each do |on|
      [*permission_to].each do |to|
        unless (permissions[on] || []).include?(to)
          return false
        end
        return true
      end
    end
  end



  # Ensure the user has a given OSMX permission
  # if not redirect them to the osm permissions page and set an instruction flash
  # @param permission_to the action which is being checked (:administer_users or :administer_faqs)
  def require_osmx_permission(permission_to)
    unless current_user && current_user.send("can_#{permission_to}?")
      # Send user to the osm permissions page
      flash[:error] = 'You are not allowed to do that.'
      redirect_back_or_to(current_user ? my_page_path : signin_path)
    end
  end

  # Ensure the current section is of a given type
  # if not redirect them to the relevant page and set an instruction flash
  # @param type a Symbol representing the type of section to require (may be :beavers, :cubs ... or an Array of allowable types)
  def require_section_type(type)
    if current_section.nil? || ![*type].include?(current_section.type)
      flash[:error] = "The current section must be a #{type} section to do that."
      redirect_back_or_to(current_user ? my_page_path : signin_path)
    end
  end

  # Forbid the current section if it is of a given type
  # if so redirect them to the relevant page and set an instruction flash
  # @param type a Symbol representing the type of section to forbid (may be :beavers, :cubs ... or an Array ot them)
  def forbid_section_type(type)
    if current_section.nil? || [*type].include?(current_section.type)
      flash[:error] = "The current section must not be a #{t} section to do that."
      redirect_back_or_to(current_user ? my_page_path : signin_path)
    end
  end


  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = 'You are not authorised to do that.'
    redirect_to(current_user ? my_page_path : signin_path)
  end


  rescue_from Osm::Error do |exception|
    log_error(exception)
    render :template => "error/osm", :status => 503, :locals => {:exception => exception}
  end


  def render_not_found(exception)
    render :template => "error/404", :status => 404
  end

  def render_error(exception)
    log_error(exception)
    email_error(exception)
    render :template => "error/500", :status => 500
  end

  def log_error(exception)
    logger.error(
      "\n\n#{exception.class} (#{exception.message}):\n    " +
      Rails.backtrace_cleaner.send(:filter, exception.backtrace).join("\n    ") +
      "\n\n"
    )
  end

  def email_error(exception)
    NotifierMailer.exception(exception, env).deliver unless Settings.read('notifier mailer - send exception to').blank?
  end

  def clean_backtrace(exception)
    if backtrace = exception.backtrace
      if defined?(RAILS_ROOT)
        backtrace.map { |line| line.sub RAILS_ROOT, '' }
      else
        backtrace
      end
    end
  end


  def set_current_section(section)
    raise ArgumentError unless section.is_a?(Osm::Section)
    session[:current_section_id] = section.id
    @current_section = section
  end
  def current_section
    @current_section ||= Osm::Section.get(current_user.osm_api, session[:current_section_id])
  end


  def current_announcements
    @current_announcements ||= (current_user ? current_user.current_announcements : Announcement.are_current.are_public)
  end

  def get_current_section_terms
    @terms ||= {}
    Osm::Term.get_for_section(current_user.osm_api, current_section).each do |term|
      @terms[term.name] = term.id
    end
    return @terms
  end

  def get_current_term_id
    @current_term_id ||= Osm::Term.get_current_term_for_section(current_user.osm_api, current_section).try(:id)
    return @current_term_id
  end

  def get_current_section_groupings
    @groupings ||= {}
    return @groupings[current_section.id] unless @groupings[current_section.id].nil?
    @groupings[current_section.id] = {}
    Osm::Grouping.get_for_section(current_user.osm_api, current_section).each do |grouping|
      @groupings[current_section.id][grouping.name] = grouping.id
    end
    return @groupings[current_section.id]
  end

  def get_all_groupings
    return @groupings unless @groupings.nil?
    @groupings = {}
    api = current_user.osm_api
    Osm::Section.get_all(api).each do |section|
      @groupings[section.id] = {}
      Osm::Grouping.get_for_section(api, section).each do |grouping|
        @groupings[section.id][grouping.name] = grouping.id
      end
    end
    return @groupings
  end

  def get_section_names(user=current_user)
    @section_names ||= Osm::Section.get_all(user.osm_api).inject({}){ |hash, section| hash[section.id] = "#{section.group_name} : #{section.name}" ; hash }
  end


  # Get the grouping name (e.g. patrol) for a given section type
  # @param type the type of section (:beavers, :cubs ...)
  # @returns a string
  def get_grouping_name(type)
    {
      :beavers=>'lodge',
      :cubs=>'six',
      :scouts=>'patrol',
      :adults=>'section'
    }[type] || 'grouping'
  end

  # Get the section general name (e.g. troop) for a given section type
  # @param type the type of section (:beavers, :cubs ...)
  # @returns a string
  def get_section_general_name(type)
    {
      :beavers=>'colony',
      :cubs=>'pack',
      :scouts=>'troop',
      :explorers=>'unit',
      :adults=>'section'
    }[type] || 'grouping'
  end

  # Create a UsageLog item setting the following values:
  #  * :at => Time.now (not overridable)
  #  * :user => current_user
  #  * :section_id => current_section.id (if current_section is not nil)
  #  * :controller => self.class.name
  #  * :action => action_name
  # @param attributes the attributes for the entry to create
  # @returns Boolean
  def log_usage(attributes)
    attributes.reverse_merge!(:user => current_user, :controller => self.class.name, :action => action_name)
    attributes[:section_id] = current_section.id if (!attributes.keys.include?(:section_id) && current_section)
    attributes[:at] = Time.now
    UsageLog.create(attributes)
  end

end
