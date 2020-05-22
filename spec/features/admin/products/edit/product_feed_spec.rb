require 'spec_helper'

describe 'Product Feed Checkbox And Unique Identifiers', type: :feature, js: true do
  stub_authorization!

  context 'editing a product' do
    before do
      create(:product, name: 'Spree Logo T-Shirt', sku: 'SP-LG-T',
                       description: 'This is one awesome Spree T-Shirt with a black logo on the back.', available_on: '2013-08-14 01:02:03')

      visit spree.admin_products_path
      within_row(1) { click_icon :edit }
    end

    it 'lists the product details with feed fields added' do
      click_link 'Details'

      expect(page).to have_css('.content-header h1', text: 'Products / Spree Logo T-Shirt')

      expect(page).to have_field(id: 'product_product_feed_active', checked: false)
      expect(page).to have_field(id: 'product_unique_identifier', with: '')
      expect(page).to have_content('GTIN')
    end

    it 'Product feed form fields can be updated' do
      find(:css, "#product_product_feed_active").set(true)
      select2 'MPN', from: 'Unique Identifier Type'
      fill_in 'product_unique_identifier', with: '90210-90210'

      click_button 'Update'

      expect(page).to have_content('successfully updated!')
      expect(page).to have_field(id: 'product_product_feed_active', checked: true)
      expect(page).to have_content('MPN')
      expect(page).to have_field(id: 'product_sku', with: 'SP-LG-T')
      expect(page).to have_field(id: 'product_unique_identifier', with: '90210-90210')
    end

    it 'Variant feed form fields are present and can be updated' do
      find(:css, "#product_product_feed_active").set(true)
      click_button 'Update'

      within('#sidebar') { click_link 'Variants' }
      click_link 'Option Values'
      click_link 'new_option_type_link'
      fill_in 'option_type_name', with: 'shirt colors'
      fill_in 'option_type_presentation', with: 'colors'
      click_button 'Create'
      expect(page).to have_content('successfully created!')

      page.find('#option_type_option_values_attributes_0_name').set('color')
      page.find('#option_type_option_values_attributes_0_presentation').set('black')
      click_button 'Update'
      expect(page).to have_content('successfully updated!')

      visit spree.admin_products_path
      within_row(1) { click_icon :edit }

      select2 'shirt', from: 'Option Types'
      wait_for { !page.has_button?('Update') }
      click_button 'Update'
      expect(page).to have_content('successfully updated!')

      within('#sidebar') { click_link 'Variants' }
      click_link 'New Variant'

      expect(page).to have_field(id: 'variant_unique_identifier', with: '')
      expect(page).to have_content('GTIN')
      expect(page).to have_field(id: 'variant_show_in_product_feed', checked: true)

      select2 'black', from: 'Colors'
      fill_in 'variant_sku', with: 'A100'

      find(:css, "#variant_show_in_product_feed").set(false)
      select2 'MPN', from: 'Unique Identifier Type'
      fill_in 'variant_unique_identifier', with: '90310-90310'

      click_button 'Create'
      expect(page).to have_content('successfully created!')

      within_row(1) { click_icon :edit }

      expect(page).to have_field(id: 'variant_unique_identifier', with: '90310-90310')
      expect(page).to have_content('MPN')
      expect(page).to have_field(id: 'variant_show_in_product_feed', checked: false)
    end
  end
end
