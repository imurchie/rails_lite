class StatusesController < ControllerBase
  def index
    statuses = ["s1", "s2", "s3"]

    render_content(statuses.to_json, "text/json")
  end

  def show
    render_content("status ##{params[:id]}", "text/text")
  end
end
