module HuBoard
  module Helpers
    def socket_backend
      return settings.socket_backend if settings.respond_to? :socket_backend
    end

    def warden
      env['warden']
    end

    def authenticate!(*args)
      warden.authenticate!(*args)
    end

    def authenticated?(*args)
      warden.authenticated?(*args)
    end

    def logout!
      warden.logout
    end

    def logged_in?
      return authenticated?(:private) || authenticated?
    end

    def encrypted_token
      encrypted = encrypt_token
      Base64.urlsafe_encode64 encrypted if encrypted
    end

    def encrypt_token
      Encryptor.encrypt user_token, :key => settings.secret_key if user_token
    end

    def user_token
      github_user.token
    end

    def decrypt_token(token)
      decoded = Base64.urlsafe_decode64 token
      Encryptor.decrypt decoded, :key => settings.secret_key
    end

    def check_token(token)
      ghee = gh token
      ghee.connection.get('./').status == 200
    end

    def github_user
      warden.user(:private) || warden.user || Hashie::Mash.new
    end

    def github_config
      return :client_id => HuBoard::App::GITHUB_CONFIG[:client_id], :client_secret => HuBoard::App::GITHUB_CONFIG[:client_secret]
    end

    def current_user
      github_user
    end

    def h(input = "")
      ERB::Util.html_escape input
    end

    def huboard(token = nil)
      Huboard::Client.new(token || user_token, github_config)
    end

    def gh(token = nil)
      huboard(token).connection
    end

    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end

  end
end
