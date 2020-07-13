# frozen_string_literal: true

WasteCarriersEngine.configure do |config|
  # Assisted digital config
  config.assisted_digital_email = ENV["WCRS_ASSISTED_DIGITAL_EMAIL"]

  # Companies House API config
  config.companies_house_host = ENV["WCRS_COMPANIES_HOUSE_URL"] || "https://api.companieshouse.gov.uk/company/"
  config.companies_house_api_key = ENV["WCRS_COMPANIES_HOUSE_API_KEY"]

  # Airbrake config
  config.airbrake_enabled = false
  config.airbrake_host = "http://localhost"
  config.airbrake_project_key = "abcde12345"
  config.airbrake_blocklist = [/password/i, /authorization/i]

  # Address lookup config
  config.address_host = ENV["ADDRESSBASE_URL"] || "http://localhost:3002"
end
WasteCarriersEngine.start_airbrake
