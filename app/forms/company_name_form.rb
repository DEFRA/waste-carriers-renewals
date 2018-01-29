class CompanyNameForm < BaseForm
  attr_accessor :business_type, :company_name

  def initialize(transient_registration)
    super
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
    self.company_name = @transient_registration.company_name
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    params[:company_name].strip! if params[:company_name].present?
    self.company_name = params[:company_name]
    attributes = { company_name: company_name }

    super(attributes, params[:reg_identifier])
  end

  validates :company_name, presence: true, length: { in: 1..255 }
end
