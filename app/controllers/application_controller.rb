class ApplicationController < ActionController::API
  around_action :switch_locale

  private

  def switch_locale(&action)
    requested = params[:locale].presence || extract_locale_from_accept_language
    locale = normalize_locale(requested) || I18n.default_locale

    I18n.with_locale(locale, &action)
  end

  def extract_locale_from_accept_language
    header = request.headers["Accept-Language"].to_s
    header.scan(/[a-z]{2}/i).first
  end

  def normalize_locale(locale)
    return if locale.blank?

    candidate = locale.to_s.downcase.to_sym
    candidate if I18n.available_locales.include?(candidate)
  end
end
