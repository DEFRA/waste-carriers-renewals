# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsRegistration, type: :model do
    subject(:order_copy_cards_registration) { build(:order_copy_cards_registration) }

    include_examples("Can use order copy cards workflow")

    context "Validations" do
      describe "reg_identifier" do
        context "when a OrderCopyCardsRegistration is created" do
          it "is not valid if the reg_identifier is in the wrong format" do
            order_copy_cards_registration.reg_identifier = "foo"
            expect(order_copy_cards_registration).to_not be_valid
          end

          it "is not valid if no matching registration exists" do
            order_copy_cards_registration.reg_identifier = "CBDU999999"
            expect(order_copy_cards_registration).to_not be_valid
          end
        end
      end
    end
  end
end
