require 'spec_helper'

describe 'Visiting Products', type: :feature, inaccessible: true do

  let(:store) { Spree::Store.default }

  let(:store_name) do
    ((first_store = Spree::Store.first) && first_store.name).to_s
  end

  before do
    visit "/products.rss"
  end

  it 'Is able to render basic XML', js: true do
    xml = Capybara.string(page.body)
    expect(xml).to have_content('<title>Spree Test Store</title>')
    expect(xml).to have_content("<description>Find out about new products first! You'll always be in the know when new products become available</description>")
    expect(xml).to have_content('<link>www.example.com</link>')
    expect(xml).to have_content('<language>en-us</language>')
  end
end
