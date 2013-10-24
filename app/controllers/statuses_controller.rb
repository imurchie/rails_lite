class StatusesController < RailsLite::ControllerBase
  def index
    statuses = ["s1", "s2", "s3"]

    render_content(statuses.to_json, "text/json")
  end

  def show
    render_content("status ##{params[:id]}", "text/text")
  end

  def silly
    render_content("status ##{params[:status_id]}\nsilly ##{params[:id]}", "text/text")
  end
end
