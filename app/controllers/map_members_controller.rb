class MapMembersController < ApplicationController
  before_action { forbid_section_type :waiting }
  before_action :require_connected_to_osm
  before_action { require_osm_permission :read, :member }


  def page
    @groupings = get_current_section_groupings
    @pin_colours = %w{red green blue yellow brown orange purple white grey black}
  end

  def data
    address_method = ['address', 'address2'].include?(params[:address]) ? params[:address] : 'address'
    members = Array.new

    Osm::Member.get_for_section(current_user.osm_api, current_section).each do |member|
      members.push ({
        :grouping_id => member.grouping_id,
        :name => member.name,
        :address => member.send(address_method)
      })
    end

    render :json => {
      :members => members,
      :groupings => get_current_section_groupings.invert
    }
    log_usage
  end

end
