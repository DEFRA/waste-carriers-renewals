# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStartFormsController < FormsController
    def new
      super(RenewalStartForm, "renewal_start_form")
    end

    def create
      super(RenewalStartForm, "renewal_start_form")
    end

    private

    def find_or_initialize_transient_registration(_id)
      # TODO: Downtime at deploy when releasing _id?
      @transient_registration = RenewingRegistration.where(_id: _id).first ||
                                RenewingRegistration.where(reg_identifier: _id).first ||
                                RenewingRegistration.new(reg_identifier: _id)
    end
  end
end
