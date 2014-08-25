class User < ActiveRecord::Base
  
  def as_json(options = {})
    {
      id: id,
      login: login,
      avatar_url: "https://avatars.githubusercontent.com/u/#{id}?v=2"
    }
  end
end
