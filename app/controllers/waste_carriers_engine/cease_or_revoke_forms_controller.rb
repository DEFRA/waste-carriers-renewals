# frozen_string_literal: true

module WasteCarriersEngine
  class CeaseOrRevokeFormsController < FormsController
    def new
      super(CeaseOrRevokeForm, "cease_or_revoke_form")
    end

    def create
      super(CeaseOrRevokeForm, "cease_or_revoke_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:cease_or_revoke_form).permit(metaData: %i[status revoked_reason])
    end

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def find_or_initialize_transient_registration(_id)
      @transient_registration ||= CeasedOrRevokedRegistration.where(reg_identifier: _id).first ||
                                  CeasedOrRevokedRegistration.where(_id: _id).first ||
                                  CeasedOrRevokedRegistration.new(reg_identifier: _id)
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
end
