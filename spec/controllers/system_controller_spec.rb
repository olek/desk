require 'rails_helper'

RSpec.describe SystemController, :type => :controller do
  describe '#healthcheck' do
    before do
      get :healthcheck
    end

    it 'contains expected message' do
      expect(response.body).to include "Here!"
    end

    it "has a 200 status code" do
      expect(response.status).to eq(200)
      expect(response).to be_ok
    end
  end
end
