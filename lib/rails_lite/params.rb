require 'uri'

class Params
  def initialize(req, route_params)
    @request = req

    @params = route_params

    @params.merge! Params.parse_www_encoded_form(request.query_string.to_s + request.body.to_s)
  end

  def [](key)
    params[key]
  end

  def to_s
    params.to_s
  end


  def self.parse_www_encoded_form(form_string = "")
    params = {}

    URI.decode_www_form(form_string).each do |key, value|
      populate_params(params, key, value)
    end

    params
  end

  private
    attr_reader :request, :params



    def self.parse_key(key)
      key.split(/\]\[|\[|\]/)
    end

    def self.populate_params(params, key, value)
      keys = parse_key(key)

      next_level = params
      (0...keys.length-1).each do |index|
        key = keys[index]

        unless next_level[key]
          next_level[key] = {}
        end

        next_level = next_level[key]
      end

      next_level[keys.last] = value
    end
end
