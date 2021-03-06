# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe RenewalPendingPaymentEmailService do
      let(:template_id) { "25a54b31-cdb0-4139-9ffe-50add03d572e" }
      let(:registration) { create(:registration, :has_required_data) }

      before do
        registration.finance_details = build(:finance_details, :has_required_data)
        registration.save
      end

      let(:reg_identifier) { registration.reg_identifier }

      let(:expected_notify_options) do
        {
          email_address: "foo@example.com",
          template_id: template_id,
          personalisation: {
            reg_identifier: reg_identifier,
            first_name: "Jane",
            last_name: "Doe",
            sort_code: "60-70-80",
            account_number: "1001 4411",
            payment_due: "100",
            iban: "GB23 NWBK 607080 10014411",
            swiftbic: "NWBK GB2L",
            currency: "Sterling"
          }
        }
      end

      describe ".run" do
        before do
          expect_any_instance_of(Notifications::Client)
            .to receive(:send_email)
            .with(expected_notify_options)
            .and_call_original
        end

        subject do
          VCR.use_cassette("notify_renewal_pending_payment_sends_an_email") do
            described_class.run(registration: registration)
          end
        end

        it "sends an email" do
          expect(subject).to be_a(Notifications::Client::ResponseNotification)
          expect(subject.template["id"]).to eq(template_id)
          expect(subject.content["subject"]).to match(
            /Payment needed for waste carrier registration CBDU/
          )
        end
      end
    end
  end
end
