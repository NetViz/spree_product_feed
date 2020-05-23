require 'spec_helper'

describe 'Tests Product Properties', type: :feature, js: true do
  stub_authorization!

  context 'A product property with presentation set to product_feed and value set' do
    let(:property) { create(:property) }
    let(:prop1) { create(:property, name: 'g:product_type', presentation: 'product_feed') }
    let(:product) { create(:product, properties: [prop1], price: '49.99', feed_active: true, unique_identifier: '80250-95240', unique_identifier_type: 'mpn' ) }

    before do
      product.tap(&:save)
      product.product_properties.first.update(value: 'Mens Baggy Socks')
      visit "/products.rss"
    end

    it "shows the correct xml tag name and value in feed" do
      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:product_type>Mens Baggy Socks</g:product_type>')
    end
  end
end
