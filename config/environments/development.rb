OSMExtender::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load = false

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_files = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Log to STDOUT
  logger = Logger.new(STDOUT)
  logger.formatter = Logger::Formatter.new
  config.logger = ActiveSupport::TaggedLogging.new(logger)
  STDOUT.sync = true

  # Set log level - :debug, :info, :warn, :error, :fatal, or :unknown
  config.log_level = :debug

  # Turn of colour in rails log
  config.colorize_logging = true

  # Automatically tag log messages
  config.log_tags = [ :uuid ]

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Setup cache
  config.cache_store = :redis_store, Rails.application.config_for(:redis)

  # Don't deliver emails, open them in a new window instead
  # Unless mailgun_api_key env var is present
  if Figaro.env.mailgun_api_key?
    config.action_mailer.delivery_method = :mailgun 
    config.action_mailer.mailgun_settings = {
      api_host: Figaro.env.mailgun_api_host || 'api.eu.mailgun.net',
      api_key: Figaro.env.mailgun_api_key!,
      domain: Figaro.env.mailgun_domain!
    }
  else
    config.action_mailer.delivery_method = :letter_opener
  end

  # URL Options
  Rails.application.routes.default_url_options = {
    :protocol => 'http',
    :host => 'localhost',
    :port => 3000,
  }
  config.action_mailer.asset_host = 'http://localhost:3000'

  # Mailer email address options (you may override this in development_custom.rb)
  ContactUsMailer.send :default, {
    :to => 'contactus@example.com',     # Can be in the format - "Name" <email_address>
  }

  # Whether to dump (or not) the schema after performing migrations
  config.active_record.dump_schema_after_migration = true

end

ActionController::Parameters.action_on_unpermitted_parameters = :raise
