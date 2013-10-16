require "active_support/core_ext"
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params={})
    @request      = req
    @response     = res
    @route_params = route_params

    @response_built = false
  end

  def session
    @session ||= Session.new(request)
  end

  def already_rendered?
    @response_built == true
  end

  def redirect_to(url)
    raise "Already rendered content" if already_rendered?

    @response_built = true

    response.status = 302
    response["Location"] = url
    session.store_session(response)
  end

  def render_content(body, content_type)
    raise "Already rendered content" if already_rendered?

    @response_built = true

    response.body = body
    response.content_type = content_type
    session.store_session(response)
  end

  def render(template_name)
    filename = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    template = ERB.new(File.read(filename))

    render_content(template.result(binding), "text/html")
  end

  def invoke_action(name)
  end


  private
    attr_reader :request, :response
end
