# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe RenewalPendingChecksEmailService do
      let(:template_id) { "d2442022-4f4c-4edd-afc5-aaa0607dabdf" }
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
            registration_type: "carrier, broker and dealer"
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
          VCR.use_cassette("notify_renewal_pending_checks_sends_an_email") do
            described_class.run(registration: registration)
          end
        end

        it "sends an email" do
          expect(subject).to be_a(Notifications::Client::ResponseNotification)
          expect(subject.template["id"]).to eq(template_id)
          expect(subject.content["subject"]).to match(
            /Your application to renew waste carriers registration CBDU\d has been received/
          )
        end
      end
    end
  end
end
