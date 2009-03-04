# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rw2_session',
  :secret      => '21f07067b2f76540950ecccb9575059d0c7d1a3c4fc5p7dfddc22e0557ff1c210866cfa48bada30cc78fa346f0f93510ed6597e6d64226cdd598541932304962'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
