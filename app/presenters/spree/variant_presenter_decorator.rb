module Spree
  module VariantPresenterDecorator

    def call
      @variants.map do |variant|
        {
          display_price: display_price(variant),
          price: variant.price_in(current_currency),
          unique_identifier: variant.unique_identifier,
          unique_identifier_type: variant.unique_identifier_type,
          display_compare_at_price: display_compare_at_price(variant),
          should_display_compare_at_price: should_display_compare_at_price(variant),
          is_product_available_in_currency: @is_product_available_in_currency,
          backorderable: backorderable?(variant),
          in_stock: in_stock?(variant),
          images: images(variant),
          option_values: option_values(variant),
        }.merge(
          variant_attributes(variant)
        )
      end
    end

  end
end

::Spree::VariantPresenter.prepend Spree::VariantPresenterDecorator 
