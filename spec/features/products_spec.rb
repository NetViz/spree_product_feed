require 'spec_helper'

describe 'Visiting products rss', type: :feature, js: true do
  stub_authorization!

  context 'expect xml' do
    before do
      create(:product, name: 'Spree Logo T-Shirt',
                       sku: 'SP-LG-T',
                       feed_active: true,
                       available_on: '2013-08-14 01:02:03',
                       unique_identifier: '80250-95240',
                       unique_identifier_type: 'mpn')

      visit "/products.rss"
    end

    let(:store) { Spree::Store.default }

    let(:store_name) do
      ((first_store = Spree::Store.first) && first_store.name).to_s
    end

    it 'Is able to render basic XML', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_content('<title>Spree Test Store</title>')
      expect(xml).to have_content("<description>Find out about new products first! You'll always be in the know when new products become available</description>")
      expect(xml).to have_content('<link>www.example.com</link>')
      expect(xml).to have_content('<language>en-us</language>')
      expect(xml).to have_content('<g:id>1-1</g:id>')
      expect(xml).to have_content('<g:mpn>80250-95240</g:mpn>')
    end

  end
end
