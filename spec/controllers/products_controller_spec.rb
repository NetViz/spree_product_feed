require 'spec_helper'

describe Spree::ProductsController, type: :controller do
  let!(:product) { create(:product, product_feed_active: true) }

  context 'Generates products in rss format' do
    it "returns page with type application/rss+xml; charset=utf-8" do
      get :index, :format => "rss"

      expect(response.content_type).to eq("application/rss+xml; charset=utf-8")
      expect(response).to have_http_status(:ok)
    end
  end
end
