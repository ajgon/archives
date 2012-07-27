class AdminController < ApplicationController
  include AdminHelper

  before_filter :fetch_resource, :except => [:create, :new, :index]
  before_filter :fetch_settings_paths, :except => [:destroy]
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
      [ k, ( (v.is_a?(Hash) and v.size == 2 and v[:date] and v[:time]) ? v[:date] + ' ' + v[:time] : v) ]
    end.flatten
    params[model.to_s.underscore] = HashWithIndifferentAccess.new(Hash[*hash])
  end

end
