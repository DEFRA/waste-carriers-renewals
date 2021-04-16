# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RegistrationActivatedService < BaseRegistrationService
      private

      def template
        "889fa2f2-f70c-4b5a-bbc8-d94a8abd3990"
      end

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: template,
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            registration_type: @registration.registration_type,
            first_name: @registration.first_name,
            last_name: @registration.last_name,
            phone_number: @registration.phone_number,
            registered_address: registered_address,
            date_registered: @registration.metaData.date_registered,
            link_to_file: "http://example.com"
          }
        }
      end
    end
  end
end
