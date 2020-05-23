require 'spec_helper'

describe 'Tests A Basic Product Added To The Feed', type: :feature, js: true do
  stub_authorization!

  context 'When a basic product is set to be shown in the product feed' do
    let(:store) { Spree::Store.default }
    let(:store_name) do
      ((first_store = Spree::Store.first) && first_store.name).to_s
    end

    before do
      create(:product, name: 'Spree Logo T-Shirt',
                       sku: 'SP-LG-T',
                       feed_active: true,
                       available_on: '2013-08-14 01:02:03',
                       unique_identifier: '80250-95240',
                       unique_identifier_type: 'mpn')

      visit "/products.rss"
    end

    it 'it renders the stock XML', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_content('<title>Spree Test Store</title>')
      expect(xml).to have_content('<link>www.example.com</link>')
      expect(xml).to have_content('<language>en-us</language>')
    end

    it 'it adds the basic product id correctly', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_content('<g:id>1-1</g:id>')
    end

    it 'it add the basic product unique_identifier and unique_identifier_type correctly', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_content('<g:id>1-1</g:id>')
      expect(xml).to have_content('<g:mpn>80250-95240</g:mpn>')
    end
  end
end
