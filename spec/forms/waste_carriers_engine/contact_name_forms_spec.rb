# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactNameForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:contact_name_form) { build(:contact_name_form, :has_required_data) }
        let(:valid_params) do
          {
            token: contact_name_form.token,
            first_name: contact_name_form.first_name,
            last_name: contact_name_form.last_name
          }
        end

        it "should submit" do
          expect(contact_name_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:contact_name_form) { build(:contact_name_form, :has_required_data) }
        let(:invalid_params) { { first_name: "", last_name: "" } }

        it "should not submit" do
          expect(contact_name_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate person name", :contact_name_form, :first_name
    include_examples "validate person name", :contact_name_form, :last_name
  end
end
