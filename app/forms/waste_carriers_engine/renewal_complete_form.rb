# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalCompleteForm < BaseForm
    include CannotSubmit

    attr_accessor :certificate_link, :contact_email, :projected_renewal_end_date, :registration_type

    def self.can_navigate_flexibly?
      false
    end

    def initialize(transient_registration)
      super

      self.certificate_link = build_certificate_link
      self.contact_email = transient_registration.contact_email
      self.projected_renewal_end_date = transient_registration.projected_renewal_end_date
      self.registration_type = transient_registration.registration_type
    end

    private

    def build_certificate_link
      registration = @transient_registration.registration
      return unless registration.present?

      id = registration.id
      root = Rails.configuration.wcrs_frontend_url
      "#{root}/registrations/#{id}/view"
    end
  end
end
