require "active_support/core_ext"
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params={})
    @request      = req
    @response     = res

    @params = Params.new(req, route_params)

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
    filename = get_view_path(template_name)
    template = ERB.new(File.read(filename))

    render_content(template.result(binding), "text/html")
  end

  def invoke_action(name)
    self.send(name)

    render(name) unless already_rendered?
  end


  private
    attr_reader :request, :response

    def get_view_path(template_name)
      bare_class = self.class.to_s.gsub("Controller", "")
      "app/views/#{bare_class.underscore}/#{template_name}.html.erb"
    end
end
