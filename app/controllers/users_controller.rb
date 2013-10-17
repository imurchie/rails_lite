class UsersController < RailsLite::ControllerBase
  def new
  end

  def create
    render_content params.to_s, "text/text"
  end

  def show
  end

  def edit
  end

  def update
    render_content params.to_s, "text/text"
  end
end
