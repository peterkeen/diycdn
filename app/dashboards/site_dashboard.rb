require "administrate/base_dashboard"

class SiteDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    domain_list: Field::Text,
    certificate: Field::Text,
    private_key: Field::Text,
    expires_at: Field::DateTime,
    upstream: Field::Text,
    push: Field::Boolean,
    s3_bucket: Field::String,
    s3_access_key_id: Field::String,
    s3_secret_access_key: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :domain_list,
    :upstream,
    :push,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :domain_list,
    :certificate,
    :private_key,
    :upstream,
    :push,
    :s3_bucket,
    :s3_access_key_id,
    :s3_secret_access_key,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :domain_list,
    :upstream,
    :push,
    :s3_bucket,
    :s3_access_key_id,
    :s3_secret_access_key,
  ].freeze

  # Overwrite this method to customize how sites are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(site)
  #   "Site ##{site.id}"
  # end
end
