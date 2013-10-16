class UsersController < ControllerBase
  def new
  end

  def create
    render_content params.to_s, "text/text"
  end

  def show
  end
end
