class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern          = pattern
    @http_method      = http_method
    @controller_class = controller_class
    @action_name      = action_name
  end

  def matches?(req)
    request_method = req.request_method.downcase.to_sym

    request_method == http_method && pattern =~ req.path
  end

  def run(req, res)
    controller = controller_class.new(req, res)
    controller.invoke_action(action_name)
  end
end

class Router
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
end
