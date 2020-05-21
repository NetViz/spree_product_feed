module Spree
  module ProductFeedHelper

    def structured_unique_identifier(product)
      product.default_variant.unique_identifier? ? product.default_variant.unique_identifier : product.unique_identifier
    end

    def structured_unique_identifier_type(product)
      product.default_variant.unique_identifier_type ? product.default_variant.unique_identifier_type : product.unique_identifier_type
    end

    def structured_brand(product)
      return '' unless product.property('g:brand').present?

      product.property('g:brand')
    end

  end
end
