class AuthenticationsController < ApplicationController
  def index
    @authentications = Authentication.all
  end

  def create
    
  end

  def destroy
    
  end
end