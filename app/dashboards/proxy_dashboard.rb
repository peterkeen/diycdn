require "administrate/base_dashboard"

class ProxyDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    external_hostname: Field::String,
    internal_hostname: Field::String,
    api_key: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    last_seen_at: Field::DateTime,
    certificates_only: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :external_hostname,
    :internal_hostname,
    :api_key,
    :last_seen_at,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :external_hostname,
    :internal_hostname,
    :api_key,
    :certificates_only,
    :created_at,
    :updated_at,
    :last_seen_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :external_hostname,
    :internal_hostname,
    :certificates_only,
  ].freeze

  # Overwrite this method to customize how proxies are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(proxy)
  #   "Proxy ##{proxy.id}"
  # end
end
