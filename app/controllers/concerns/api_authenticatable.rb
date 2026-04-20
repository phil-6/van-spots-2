module ApiAuthenticatable
  extend ActiveSupport::Concern

  private

  def authenticate_api_request!
    auth_header = request.headers["Authorization"]

    if auth_header.present?
      # External request with Bearer token
      authenticate_with_bearer_token!(auth_header)
    else
      # No auth header - only allow same-origin requests (internal map page etc.)
      authenticate_same_origin!
    end
  end

  def authenticate_with_bearer_token!(auth_header)
    token = auth_header.to_s.match(/\ABearer\s+(.+)\z/i)&.captures&.first

    if token.blank?
      render json: { error: "Invalid Authorization header format. Use: Bearer <token>" }, status: :unauthorized
      return
    end

    user = User.authenticate_by_api_token(token)
    if user.nil?
      render json: { error: "Invalid API token" }, status: :unauthorized
    end
  end

  def authenticate_same_origin!
    # Allow requests that have a valid Rails session (logged-in user)
    # or that come with a valid CSRF token (same-origin browser request)
    return if user_signed_in?
    return if valid_request_origin?

    render json: { error: "API token required. Use Authorization: Bearer <token>" }, status: :unauthorized
  end

  def valid_request_origin?
    # Check if the request has a matching CSRF token (set by Rails for same-origin pages)
    # or originates from the same host
    return true if request.headers["X-CSRF-Token"].present? && valid_authenticity_token?(session, request.headers["X-CSRF-Token"])
    return true if request.origin.present? && request.origin == request.base_url
    return true if request.referer.present? && URI.parse(request.referer).host == request.host

    false
  rescue URI::InvalidURIError
    false
  end
end
