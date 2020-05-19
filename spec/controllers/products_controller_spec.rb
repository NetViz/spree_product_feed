require 'spec_helper'

describe Spree::ProductsController, type: :controller do
  let!(:product) { create(:product, product_feed_active: true) }

  context 'index products in rss format' do
    it "returns blank rss xml" do
      get :index, :format => "rss"

      response.content_type.should eq("application/rss+xml; charset=utf-8")
    end
  end
end
