require 'spec_helper'

describe 'Tests A Product With Variants Added To The Feed', type: :feature, js: true do
  stub_authorization!


  context 'When a product with variants is set to be shown in the product feed' do
    let(:store) { Spree::Store.default }

    let(:store_name) do
      ((first_store = Spree::Store.first) && first_store.name).to_s
    end

    let(:product) do
        FactoryBot.create(:base_product,
                              description: 'Testing sample',
                              name: 'Sample',
                              price: '19.99',
                              sku: 'SP-LG-T',
                              feed_active: true,
                              available_on: '2013-08-14 01:02:03',
                              unique_identifier: '80250-95240',
                              unique_identifier_type: 'mpn' )
    end

      let(:option_type) { create(:option_type) }
      let(:option_value1) { create(:option_value, name: 'small', presentation: 'S', option_type: option_type) }
      let(:option_value2) { create(:option_value, name: 'medium', presentation: 'M', option_type: option_type) }
      let(:option_value3) { create(:option_value, name: 'large', presentation: 'L', option_type: option_type) }
      let(:variant1) { create(:variant, product: product, option_values: [option_value1], price: '49.99', unique_identifier: 'ver1-1', unique_identifier_type: 'mpn' ) }
      let(:variant2) { create(:variant, product: product, option_values: [option_value2], price: '69.99', unique_identifier: 'ver1-2', unique_identifier_type: 'mpn', show_in_product_feed: false  ) }
      let(:variant3) { create(:variant, product: product, option_values: [option_value3], price: '89.99', unique_identifier: 'ver1-3', unique_identifier_type: 'mpn' ) }

    before do
      price1 = Spree::Price.find_by(variant: variant1)
      price2 = Spree::Price.find_by(variant: variant2)
      price3 = Spree::Price.find_by(variant: variant3)
      price1.update(compare_at_amount: '149.99')
      price2.update(compare_at_amount: '169.99')
      price3.update(compare_at_amount: '79.99')
      price1.save
      price2.save
      price3.save

      product.master.prices.first.update(compare_at_amount: 29.99)
      product.master.stock_items.update_all count_on_hand: 10, backorderable: true
      product.option_types << option_type
      product.variants << [variant1, variant2, variant3]
      product.tap(&:save)

      visit "/products.rss"
    end

    it "it adds the variant id's correctly", js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_content('<g:id>1-1-2</g:id>')
      expect(xml).to have_content('<g:id>1-1-4</g:id>')
    end

    it 'it adds each variant unique_identifier and unique_identifier_type correctly', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_content('<g:mpn>ver1-1</g:mpn>')
      expect(xml).to have_content('<g:mpn>ver1-3</g:mpn>')
    end

    it 'it sets the correct item_group_id for the varinats', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_content('<g:item_group_id>1-1</g:item_group_id>')
    end

    it 'it removes the variant that is not to be shown in the product feed', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to_not have_content('<g:id>1-1-3</g:id>')
      expect(xml).to_not have_content('<g:mpn>ver1-2</g:mpn>')
    end

  end
end
