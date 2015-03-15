class TemplatesController < ApplicationController

  def index
    render 'index', layout: 'application'
  end

  # GET /template/:entity/:template
  def template
      render :template => "templates/#{params[:entity]}/#{params[:template]}", layout: nil
  end
end