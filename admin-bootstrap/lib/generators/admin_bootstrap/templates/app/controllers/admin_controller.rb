class AdminController < ApplicationController
  include AdminHelper

  before_filter :fetch_resource, :except => [:create, :new, :index, :ajax]
  before_filter :fetch_settings_paths, :except => [:destroy, :ajax]
  before_filter :redirect_disabled_actions, :except => [:create, :ajax]
  before_filter :authenticate_user!
  before_filter :check_abilities

  def index
    @model = model

    respond_to do |format|
      format.html
      format.json do
        render :json => (AdminBootstrap::DataTable.new(model, params) do |result|
          render_to_string(:partial => 'actions', :formats => [:html], :locals => {:resource => result})
        end)
      end
    end
  end

  def new
    @resource = model.new
  end

  def edit
  end

  def show
  end

  def create
    parse_params

    @resource = model.new(params[model.to_s.underscore])

    if @resource.save
      redirect_to({:action => :show, :id => @resource.id}, {:notice => "#{model.to_s} was successfully created!"})
    else
      render :new
    end
  end

  def update
    parse_params
    if @resource.update_attributes(params[model.to_s.underscore])
      redirect_to({:action => :show, :id => @resource.id}, {:notice => "#{model.to_s} was successfully updated."})
    else
      render :edit
    end
  end

  def destroy
    respond_to do |format|
      format.html do
        if @resource.destroy
          redirect_to({:action => :index}, {:notice => "#{model.to_s} was successfully deleted."})
        else
          redirect_to({:action => :index}, {:alert => "There was a problem while deleting #{model.to_s}."})
        end
      end
      format.json do
        model.destroy_all("id IN (#{params[:id].split(',').collect(&:to_i).join(',')})")
        render :json => {:code => 'SUCCESS', :message => 'Rows deleted successfully'}
      end
    end
  end

  def ajax
    respond_to do |format|
      format.json do
        if params[:plugin] and AdminBootstrap::Plugins::Base.subclasses.collect {|c| c.name.underscore.split('/').last}.include?(params[:plugin] + '_plugin')
          render :json => AdminBootstrap::Plugins::Base.ajax_call(params[:plugin].to_sym, params)
        else
          raise 'Invalid parameters'
        end
      end
    end

  end

  private
  def fetch_resource
    @resource = model.find(params[:id])
  end

  def fetch_settings_paths
    @settings_paths = (admin_controllers).collect do |controller|
      {
          :name => controller.controller_name.humanize,
          :params => {:controller => controller.controller_path, :action => :index}
      }
    end
  end

  def redirect_disabled_actions
    return if params[:controller] == 'admin/dashboard'
    disabled_actions = model.admin_options[:disabled_actions]
    if disabled_actions and disabled_actions[:enabled] and disabled_actions[:value].include?(params[:action].to_sym)
      redirect_to :controller => 'admin/dashboard'
      return true
    end
    return false
  end

  def model
    model_for self.class
  end

  def parse_params

    hash = params[model.to_s.underscore].collect do |k,v|
      if !["issue_ids", "event_ids"].include?(k)
        [ k, ( (v.is_a?(Hash) and v.size == 2 and v[:date] and v[:time]) ? v[:date] + ' ' + v[:time] : v) ]
      else
        []
      end
    end.flatten
    if  params[model.to_s.underscore]["issue_ids"]
      hash << "issue_ids"
      hash << params[model.to_s.underscore]["issue_ids"]
    end

    if  params[model.to_s.underscore]["event_ids"]
      hash << "event_ids"
      hash << params[model.to_s.underscore]["event_ids"]
    end
    params[model.to_s.underscore] = HashWithIndifferentAccess.new(Hash[*hash])

  end

  def check_abilities
    redirect_to :back, :alert => "You don't have permission to see that page" unless current_user.full_control?
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end

  def check_moderator_abilities
    redirect_to :back, :alert => "You don't have permission to see that page" unless current_user.partial_control?
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end

end
