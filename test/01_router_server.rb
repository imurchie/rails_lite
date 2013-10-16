require 'active_support/core_ext'
require 'json'
require 'webrick'
require 'rails_lite'

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "app", "controllers")
require "users_controller"
require "statuses_controller"


# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html
server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

server.mount_proc '/' do |req, res|
  router = Router.new
  router.draw do
    # resources :user, :only => [:new, :create, :show]
    get "/users/new", UsersController, :new
    post "/users/create", UsersController, :create
    get "/users/:id", UsersController, :show

    get "/statuses", StatusesController, :index

    # uncomment this when you get to route params
    # get Regexp.new("^/statuses/(?<id>\\d+)$"), StatusesController, :show
    get "/statuses/:id", StatusesController, :show
    get "/statuses/:status_id/silliness/:id", StatusesController, :silly
  end

  route = router.run(req, res)
end

server.start
