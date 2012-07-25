class AdminController < ApplicationController
  include AdminHelper

  before_filter :fetch_resource, :only => [:edit, :update, :show, :destroy]
  before_filter :fetch_settings_paths, :only => [:index, :new, :edit, :show]
  before_filter :redirect_disabled_actions, :except => [:create]

  def index
    @model = model

    respond_to do |format|
      format.html
      format.json do
        render :json => dataTables_response_for(model)
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

  private
  def fetch_resource
    @resource = model.find(params[:id])
  end

  def fetch_settings_paths
    Dir.glob(File.join(Rails.root, 'app', 'controllers', 'admin', '*')).each do |controller_file|
      require controller_file
    end unless Rails.env == 'production'
    @settings_paths = (AdminController.subclasses - [Admin::DashboardController]).collect do |controller|
      {
          :name => controller.controller_name.humanize,
          :params => {:controller => controller.controller_path, :action => :index}
      }
    end
  end

  def redirect_disabled_actions
    return if params[:controller] == 'admin/dashboard'
    disabled_actions = model.admin_option_value(:disabled_actions)
    if disabled_actions and disabled_actions.include?(params[:action].to_sym)
      redirect_to :controller => 'admin/dashboard'
      return true
    end
    return false
  end

  def model
    begin
      return File.basename(self.class.to_s.underscore).gsub(/_controller$/, '').classify.constantize
    rescue NameError
      return false
    end
  end

  def parse_params
    params[model.to_s.underscore] = HashWithIndifferentAccess.new(Hash[*params[model.to_s.underscore].collect {|k,v| [k,(v.is_a?(Hash) ? v[:date] + ' ' + v[:time] : v)]}.flatten])
  end

end
