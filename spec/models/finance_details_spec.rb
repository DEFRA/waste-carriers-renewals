require "rails_helper"

RSpec.describe FinanceDetails, type: :model do
  before do
    allow(Rails.configuration).to receive(:renewal_charge).and_return(100)
    allow(Rails.configuration).to receive(:type_change_charge).and_return(25)
    allow(Rails.configuration).to receive(:card_charge).and_return(10)
  end

  let(:transient_registration) { build(:transient_registration, :has_required_data, temp_cards: 0) }

  describe "new_finance_details" do
    let(:finance_details) { FinanceDetails.new_finance_details(transient_registration) }

    it "should include 1 order" do
      order_count = finance_details.orders.length
      expect(order_count).to eq(1)
    end

    it "should have the correct balance" do
      expect(finance_details.balance).to eq(10_000)
    end
  end

  describe "update_balance" do
    let(:finance_details) { build(:finance_details) }

    it "should have the correct balance" do
      finance_details.update_balance
      expect(finance_details.balance).to eq(0)
    end

    context "when there is an order" do
      before do
        finance_details.orders = [Order.new_order(transient_registration)]
      end

      it "should have the correct balance" do
        finance_details.update_balance
        expect(finance_details.balance).to eq(10_000)
      end

      context "when there is also a payment" do
        before do
          finance_details.payments = [build(:payment, amount: 5_000)]
        end

        it "should have the correct balance" do
          finance_details.update_balance
          expect(finance_details.balance).to eq(5_000)
        end
      end
    end

    context "when there is a payment only" do
      before do
        finance_details.payments = [build(:payment, amount: 5_000)]
      end

      it "should have the correct balance" do
        finance_details.update_balance
        expect(finance_details.balance).to eq(-5_000)
      end
    end
  end
end
