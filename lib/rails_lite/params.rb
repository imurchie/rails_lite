require 'uri'

class Params
  def initialize(req, route_params)
    @request = req
    @route_params = route_params

    @params = parse_www_encoded_form(request.query_string)
  end

  def [](key)
    params[key]
  end

  def to_s
    params.to_s
  end


  private
    attr_reader :request, :params

    def parse_www_encoded_form(www_encoded_form)
      params = {}

      # URI::decode_www_form returns an array of two-element arrays
      URI.decode_www_form(www_encoded_form).each do |k, v|
        params[k] = v
      end

      params
    end

    def parse_key(key)
    end
end
