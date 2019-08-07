class ValidationTokenController < ApplicationController

  namespace "/validation_token" do
    get '/login' do 
      erb:'login.html'
    end
  end