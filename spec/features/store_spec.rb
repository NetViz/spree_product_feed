require 'spec_helper'

describe 'Test Store Details Are Added To The Feed', type: :feature, js: true do
  stub_authorization!

  context 'Set the store details' do
    let(:store) { Spree::Store.default }
    let(:store_name) do
      ((first_store = Spree::Store.first) && first_store.name).to_s
    end

    before do
      visit "/products.rss"
    end

    it 'it renders the store details correctly' do
      xml = Capybara.string(page.body)

      expect(xml).to have_text('<title>Spree Test Store</title>')
      expect(xml).to have_text('<link>www.example.com</link>')
      expect(xml).to have_text('<language>en-us</language>')
    end
  end
end
