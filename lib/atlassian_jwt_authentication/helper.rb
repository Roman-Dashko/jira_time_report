module AtlassianJwtAuthentication
  module Helper
    # protected
    # class << self
      # Returns the current JWT auth object if it exists
      def current_jwt_auth
        @jwt_auth ||= session[:jwt_auth] ? JwtToken.where(id: session[:jwt_auth]).first : nil
      end

      # Sets the current JWT auth object
      def current_jwt_auth=(jwt_auth)
        session[:jwt_auth] = jwt_auth.nil? ? nil : jwt_auth.id
        @jwt_auth = jwt_auth
      end

      # Returns the current JWT User if it exists
      def current_jwt_user
        @jwt_user ||= session[:jwt_user] ? JwtUser.where(id: session[:jwt_user]).first : nil
      end

      # Sets the current JWT user
      def current_jwt_user=(jwt_user)
        session[:jwt_user] = jwt_user.nil? ? nil : jwt_user.id
        @jwt_user = jwt_user
      end
    # end
  end
end