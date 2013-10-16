require 'json'
require 'webrick'

class Session
  COOKIE_NAME = "_rails_lite_app"

  def initialize(req)
    @request = req

    @cookie = find_cookie
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    res.cookies.push WEBrick::Cookie.new(Session::COOKIE_NAME, @cookie.to_json)
  end


  private
    attr_reader :request

    def find_cookie
      webrick_cookie = nil
      request.cookies.each do |cookie|
        if cookie.name == Session::COOKIE_NAME
          webrick_cookie = cookie
          break
        end
      end

      return {} unless webrick_cookie

      JSON.parse(webrick_cookie.value)
    end
end
