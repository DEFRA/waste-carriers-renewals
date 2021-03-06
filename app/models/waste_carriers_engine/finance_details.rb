# frozen_string_literal: true

module WasteCarriersEngine
  class FinanceDetails
    include Mongoid::Document

    embedded_in :registration,           class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration,      class_name: "WasteCarriersEngine::PastRegistration"
    embedded_in :transient_registration, class_name: "WasteCarriersEngine::TransientRegistration"
    embeds_many :orders,                 class_name: "WasteCarriersEngine::Order"
    embeds_many :payments,               class_name: "WasteCarriersEngine::Payment"

    accepts_nested_attributes_for :orders, :payments

    field :balance, type: Integer

    validates :balance,
              presence: true

    def self.new_renewal_finance_details(transient_registration, method, current_user)
      user_email = current_user&.email || transient_registration.contact_email
      finance_details = FinanceDetails.new
      finance_details.transient_registration = transient_registration
      finance_details[:orders] = [Order.new_order(transient_registration, method, user_email)]
      finance_details.update_balance
      finance_details.save!
      finance_details
    end

    # These amounts are used in a number of finance operations.
    def overpaid_balance
      @_overpaid_balance ||= balance <= 0 ? (balance * -1) : 0
    end

    def unpaid_balance
      @_unpaid_balance ||= [0, balance].max
    end

    # This returns any amount of difference of the balance from 0
    def zero_difference_balance
      @_zero_difference_balance ||= [overpaid_balance, unpaid_balance].max
    end

    def update_balance
      order_balance = orders.sum { |item| item[:total_amount] }
      # Select payments where the type is not WORLDPAY, or if it is, the status is AUTHORISED
      payment_balance = payments.any_of({ :payment_type.ne => "WORLDPAY" },
                                        world_pay_payment_status: "AUTHORISED").sum { |item| item[:amount] }
      self.balance = order_balance - payment_balance
    end
  end
end
