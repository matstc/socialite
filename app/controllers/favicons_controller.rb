class FaviconsController < ApplicationController
  before_filter :require_admin!

  # POST /favicon
  # POST /favicon.xml
  def create
    @favicon = Favicon.new(params[:favicon])

    respond_to do |format|
      if @favicon.save
        format.html { redirect_to(new_logo_url, :notice => 'The new favicon was uploaded.') }
      else
        flash[:alert] = @favicon.errors
        format.html { render 'logos/new' }
      end
    end
  end

end
