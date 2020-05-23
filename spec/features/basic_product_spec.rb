require 'spec_helper'

describe 'Test A Basic Product In The Feed', type: :feature, js: true do
  stub_authorization!

  let(:product) do
    FactoryBot.create(:base_product,
      name: 'Mens Socks',
      meta_description: 'Pair of mens socks',
      feed_active: true, unique_identifier: '80250-95240',
      unique_identifier_type: 'mpn' )
  end

  context 'A product set to be shown in the product feed' do
    it 'shows the xml item, id, name and description correctly' do
      product.tap(&:save)
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:id>1-1</g:id>')
      expect(xml).to have_text('<g:title>Mens Socks</g:title>')
      expect(xml).to have_text('<g:description>Pair of mens socks</g:description>')
    end
  end

  context 'Check the unique identifier' do
    it 'shows type GTIN with the correct barcode' do
      product.update(unique_identifier: '8025082379237', unique_identifier_type: 'gtin')
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:id>1-1</g:id>')
      expect(xml).to have_text('<g:gtin>8025082379237</g:gtin>')
    end

    it 'shows type MPN with the correct manufacturers part number' do
      product.update(unique_identifier: 'MPN901222', unique_identifier_type: 'mpn')
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:id>1-1</g:id>')
      expect(xml).to have_text('<g:mpn>MPN901222</g:mpn>')
    end
  end

  context 'Make sure the product availability' do
    it 'shows OUT OF STOCK when count on hand is 0 and backorderable is false' do
      product.master.stock_items.update_all count_on_hand: 0, backorderable: false
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:availability>out of stock</g:availability>')
    end

    it 'shows IN STOCK when count on hand is 3 and backorderable is true' do
      product.master.stock_items.update_all count_on_hand: 3, backorderable: true
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:availability>in stock</g:availability>')
    end

    it 'shows OUT OF STOCK when count on hand is 0 and backorderable is true' do
      product.master.stock_items.update_all count_on_hand: 0, backorderable: true
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:availability>out of stock</g:availability>')
    end
  end

  context 'When the product copare price is set it' do
    it 'shows sale price if compare at price is higher than master price' do
      product.master.prices.first.update(compare_at_amount: 69.99)
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:sale_price>19.99 USD</g:sale_price>')
      expect(xml).to have_text('<g:price>69.99 USD</g:price>')
    end

    it 'does not show a sale price if compare at price is less than selling price' do
      product.master.prices.first.update(compare_at_amount: 9.99)
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).not_to have_text('<g:sale_price>9.99 USD</g:sale_price>')
      expect(xml).to have_text('<g:price>19.99 USD</g:price>')
    end

    it 'does not show a sale price if compare at price nil' do
      product.master.prices.first.update(compare_at_amount: nil)
      visit "/products.rss"

      xml = Capybara.string(page.body)
      expect(xml).not_to have_text('<g:sale_price>9.99 USD</g:sale_price>')
      expect(xml).to have_text('<g:price>19.99 USD</g:price>')
    end
  end
end
