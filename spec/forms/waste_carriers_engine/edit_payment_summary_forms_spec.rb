# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditPaymentSummaryForm, type: :model do
    describe "#submit" do
      let(:edit_payment_summary_form) { build(:edit_payment_summary_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) do
          { temp_payment_method: "card" }
        end

        it "should submit" do
          expect(edit_payment_summary_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        before do
          expect(edit_payment_summary_form).to receive(:valid?).and_return(false)
        end

        it "should not submit" do
          expect(edit_payment_summary_form.submit({})).to eq(false)
        end
      end
    end
  end
end
