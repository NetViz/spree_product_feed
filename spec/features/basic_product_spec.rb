require 'spec_helper'

describe 'Tests A Basic Product In The Feed', type: :feature, js: true do
  stub_authorization!

  let(:product) do
    FactoryBot.create(:base_product, feed_active: true, unique_identifier: '80250-95240', unique_identifier_type: 'mpn' )
  end

  context 'When a product is set to be shown in the product feed' do
    it 'it adds the product item and id correctly' do
      product.tap(&:save)
      visit "/products.rss"
      
      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:id>1-1</g:id>')
    end
  end

  context 'Test Unique Idetifiers' do
    it 'it has type GTIN with new code' do
      product.update(unique_identifier: '8025082379237', unique_identifier_type: 'gtin')
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:id>1-1</g:id>')
      expect(xml).to have_text('<g:gtin>8025082379237</g:gtin>')
    end

    it 'it has type MPN with new code' do
      product.update(unique_identifier: 'MPN901222', unique_identifier_type: 'mpn')
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:id>1-1</g:id>')
      expect(xml).to have_text('<g:mpn>MPN901222</g:mpn>')
    end
  end

  context 'Test product availability renderes XML availability correctly' do
    it 'When count on hand is 0 and backorderable is false, the availability is OUT OF STOCK' do
      product.master.stock_items.update_all count_on_hand: 0, backorderable: false
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:availability>out of stock</g:availability>')
    end

    it 'When count on hand is 3 and backorderable is true, the availability is IN STOCK' do
      product.master.stock_items.update_all count_on_hand: 3, backorderable: true
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:availability>in stock</g:availability>')
    end

    it 'When count on hand is 0 and backorderable is true, the availability is OUT OF STOCK' do
      product.master.stock_items.update_all count_on_hand: 0, backorderable: true
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:availability>out of stock</g:availability>')
    end
  end

end
