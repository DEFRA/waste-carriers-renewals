# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsCompletionService do
    describe ".run" do
      let(:finance_details) { double(:finance_details) }
      let(:transient_finance_details) { double(:transient_finance_details) }
      let(:registration) { double(:registration, finance_details: finance_details) }
      let(:transient_registration) do
        double(
          :transient_registration,
          registration: registration,
          finance_details: transient_finance_details
        )
      end

      skip "TODO: when the registration have not been paid in full" do
        pending "completes an order and sends an awaiting payment email" do
        end
      end

      it "completes an order and sends a confirmation email" do
        orders = double(:orders)
        payments = double(:payments)
        transient_order = double(:transient_order)
        transient_payment = double(:transient_payment)
        mailer = double(:mailer)

        # Merge finance details
        allow(registration).to receive(:finance_details).and_return(finance_details)
        allow(transient_registration).to receive(:finance_details).and_return(transient_finance_details)
        expect(finance_details).to receive(:update_balance)

        ## Merge orders
        allow(finance_details).to receive(:orders).and_return(orders)
        allow(transient_finance_details).to receive(:orders).and_return([transient_order])
        expect(orders).to receive(:<<).with(transient_order)

        ## Merge payments
        expect(finance_details).to receive(:payments).and_return(payments).twice
        expect(transient_finance_details).to receive(:payments).and_return([transient_payment]).twice
        expect(payments).to receive(:<<).with(transient_payment)

        # Deletes transient registration
        expect(transient_registration).to receive(:delete)

        # Save registration
        expect(registration).to receive(:save!)

        # Send email
        expect(transient_registration).to receive(:unpaid_balance?).and_return(false)
        expect(OrderCopyCardsMailer).to receive(:send_order_completed_email).and_return(mailer)
        expect(mailer).to receive(:deliver_now)

        described_class.run(transient_registration)
      end
    end
  end
end
