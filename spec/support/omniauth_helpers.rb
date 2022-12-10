# frozen_string_literal: true

module OmniauthHelpers
  def discord_oauth(uid, image)
    OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new(
      {
        provider: 'discord',
        uid:,
        info: {
          image:
        }
      }
    )
  end
end
