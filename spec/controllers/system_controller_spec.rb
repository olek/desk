require 'rails_helper'

RSpec.describe SystemController, :type => :controller do
  describe '#healthcheck' do
    before do
      get :healthcheck
    end

    it 'tick tocks' do
      expect(response.body).to eq "Tick-tock"
    end

    it "has a 200 status code" do
      expect(response.status).to eq(200)
      expect(response).to be_ok
    end
  end
end
