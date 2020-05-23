require 'spec_helper'

describe 'Tests A Product With Variants Added To The Feed', type: :feature, js: true do
  stub_authorization!

  context 'When a product with variants is set to be shown in the product feed' do
    let(:store) { Spree::Store.default }

    let(:store_name) do
      ((first_store = Spree::Store.first) && first_store.name).to_s
    end

    let(:product) do
      FactoryBot.create(:base_product, feed_active: true, unique_identifier: '80250-95240', unique_identifier_type: 'mpn' )
    end

    let(:option_type) { create(:option_type) }
    let(:option_value1) { create(:option_value, name: 'small', presentation: 'S', option_type: option_type) }
    let(:option_value2) { create(:option_value, name: 'medium', presentation: 'M', option_type: option_type) }
    let(:option_value3) { create(:option_value, name: 'large', presentation: 'L', option_type: option_type) }
    let(:variant1) { create(:variant, product: product, option_values: [option_value1], price: '49.99', unique_identifier: 'ver1-1', unique_identifier_type: 'mpn' ) }
    let(:variant2) { create(:variant, product: product, option_values: [option_value2], price: '69.99', unique_identifier: 'ver1-2', unique_identifier_type: 'mpn', show_in_product_feed: false  ) }
    let(:variant3) { create(:variant, product: product, option_values: [option_value3], price: '89.99', unique_identifier: 'ver1-3', unique_identifier_type: 'mpn' ) }

    before do
      product.option_types << option_type
      product.variants << [variant1, variant2, variant3]
      product.tap(&:save)

      visit "/products.rss"
    end

    it "it adds the variant id's correctly", js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:id>1-1-2</g:id>')
      expect(xml).to have_text('<g:id>1-1-4</g:id>')
    end

    it 'it adds each variant unique_identifier and unique_identifier_type correctly', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:mpn>ver1-1</g:mpn>')
      expect(xml).to have_text('<g:mpn>ver1-3</g:mpn>')
    end

    it 'it sets the correct item_group_id for the varinats', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to have_text('<g:item_group_id>1-1</g:item_group_id>')
    end

    it 'it removes the variant that is not to be shown in the product feed', js: true do
      xml = Capybara.string(page.body)
      expect(xml).to_not have_text('<g:id>1-1-3</g:id>')
      expect(xml).to_not have_text('<g:mpn>ver1-2</g:mpn>')
    end
  end
end
