# Generic constants that pertain to more than one model go here.
module Constants
  NONE = "None".freeze
  UNCONFIRMED_FLED = 'Unconfirmed (Fled)'.freeze
  MULTIPLE = "Multiple".freeze
  VARIOUS = 'Various*'.freeze

  ERROR_BLANK_FIELD = "Can't be blank".freeze

  SBI_DEFINITION = "a bodily injury that involves a substantial risk of death, unconsciousness," \
                   " protracted and obvious disfigurement, or protracted loss or impairment of" \
                   " the function of a bodily member or organ".freeze

  BRANDING_WHITELABEL = 'whitelabel'.freeze
  BRANDING_URSUS = 'ursus'.freeze
  AVAILABLE_BRANDINGS = [BRANDING_WHITELABEL, BRANDING_URSUS].freeze
end
