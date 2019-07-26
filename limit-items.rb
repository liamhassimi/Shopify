# ================================ Customizable Settings ================================
# Products to be limited, value must be "product" or "tag"
LIMITED_ITEM_TRIGGER_TYPE = "product"

# Value can be a product tag or an array of product IDs depending on the above settings value
LIMITED_ITEM_PRODUCT_ID = 2299352318011

# Quantity limit for all affected products
MAX_QUANTITY_LIMIT = 1
QUANTITY_LIMIT = 0

# Tag to block additional purchases of the product
CUSTOMER_TAG = 'AT3152-999_customer'

# ================================ Script code (do not edit) ================================
# Makes quantities directly editable
class LineItem
  attr_writer :quantity
end

class QuantityLimitCampaign
  def initialize(trigger_type, trigger_item, max_limit, limit, tag)
    @trigger_type = trigger_type
    @trigger_id = trigger_item
    @max_limit = max_limit
    @limit = limit
    @customer_tag = tag
  end

  def run(cart)
    variant_count = 0
    customer_has_tag = !cart.customer.nil? and cart.customer.tags.include?(@customer_tag)
    
    cart.line_items.each do |item|
      if customer_has_tag 
        item.quantity = @limit
        next
      end
      
      if @trigger_type == 'product' && @trigger_id == item.variant.product.id
        variant_count += 1

        if variant_count == 1 && item.quantity > 1
          item.quantity = @max_limit
        elsif variant_count > 1
          item.quantity = @limit
        end
        
      end
    end
  end
end

CAMPAIGNS = [
  QuantityLimitCampaign.new(
    LIMITED_ITEM_TRIGGER_TYPE,
    LIMITED_ITEM_PRODUCT_ID,
    MAX_QUANTITY_LIMIT,
    QUANTITY_LIMIT,
    CUSTOMER_TAG
  ),
]

CAMPAIGNS.each do |campaign|
  campaign.run(Input.cart)
end

Output.cart = Input.cart
