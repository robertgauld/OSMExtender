if Figaro.env.recaptcha_public_key? && Figaro.env.recaptcha_private_key?
  Recaptcha.configure do |config|
    config.site_key = Figaro.env.recaptcha_public_key!
    config.secret_key = Figaro.env.recaptcha_private_key!
  end
end
