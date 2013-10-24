require "active_support/core_ext"
require_relative "params"

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name, :route_params

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern          = parse_pattern(pattern)
    @http_method      = http_method
    @controller_class = controller_class
    @action_name      = action_name

    @route_params = {}
  end

  def matches?(req)
    request_method = parse_request_method(req)

    if request_method == http_method && md = pattern.match(req.path)

      pattern.named_captures.each do |key, value|
        route_params[key.to_sym] = md[value.first]
      end

      return true
    end

    false
  end

  def run(req, res)
    controller = controller_class.new(req, res, route_params)
    controller.invoke_action(action_name)
  end

  def to_s
    "Route: [#{http_method}] #{pattern.to_s} => #{controller_class}##{action_name}"
  end


  private
    # parse Rails-style route parameters into the Regexp used here
    def parse_pattern(pattern)
      return pattern if pattern.is_a?(Regexp)

      pattern = pattern.split(/\//).map do |part|
        if /^:/ =~ part
          "(?<#{part.sub(":", "")}>\\d+)"
        else
          part
        end
      end.join("/")

      Regexp.new("^#{pattern}$")
    end

    def parse_request_method(request)
      method = request.request_method.downcase

      if method == "post"
        # POST requests can be POST, PUT, or DELETE
        _method = Params.parse_www_encoded_form(request.body)["_method"]
        method = _method unless _method.nil?
      end

      method.to_sym
    end
end

class Router
  ROUTE_METHODS = {
    :new => :get,
    :create => :post,
    :edit => :get,
    :update => :put,
    :index => :get,
    :show => :get,
    :destroy => :delete
  }

  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, http_method, controller_class, action_name)
    routes << Route.new(pattern, http_method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval &proc
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def resources(name, options = {})
    options = Router.default_resources_options.merge(options)

    options[:only].each do |action_name|
      # get "/users/new", UsersController, :new
      self.send(Router::ROUTE_METHODS[action_name],
        "/#{name}/#{action_name}",
        "#{action_name.camelize}Controller".constantize,
        action_name)
    end
  end

  def match(req)

  end

  def run(req, res)
    matched_route = nil

    routes.each do |route|
      if route.matches?(req)
        matched_route = route
        break
      end
    end

    if matched_route
      matched_route.run(req, res)
    else
      res.status = 404
    end
  end


  private
    def self.default_resources_options
      { :only => [:new, :create, :edit, :update, :index, :show, :destroy] }
    end
end
