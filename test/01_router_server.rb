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
    get Regexp.new("^/users/new$"), UsersController, :new
    post Regexp.new("^/users/create$"), UsersController, :create
    get Regexp.new("^/users(?<id>\\d+)$"), UsersController, :show

    get Regexp.new("^/statuses$"), StatusesController, :index

    # uncomment this when you get to route params
    get Regexp.new("^/statuses/(?<id>\\d+)$"), StatusesController, :show
  end

  route = router.run(req, res)
end

server.start
