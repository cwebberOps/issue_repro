# We use the chef_handler recipe/cookbook so that we can register the an
# exception handler. The only issue here is that we register it inside the
# recipe so we are only going to get converge time exceptions.
include_recipe 'chef_handler::default'

# We include the hipchat recipe here so the libraries and such can be in place
# so we are later able to use the hipchat_notify recipe
include_recipe 'hipchat::default'

hipchat_creds = {
  'token' => 'an_token',
  'room' => 'an_room'
}

# This is the actual hipchat handler. We place it on disk so we can register it.
cookbook_file "hipchat.rb" do
  path File.join(node["chef_handler"]["handler_path"], 'hipchat.rb')
end.run_action(:create)

# This actually registers the hipchat handler we wrote out to disk above. It is 
# the firs time we make use of the sensitive attribute. It is important to not 
# expose our creds in the output to the delivery server.
chef_handler "BuildCookbook::HipChatHandler" do
  source File.join(node["chef_handler"]["handler_path"], 'hipchat.rb')
  arguments [hipchat_creds['token'], hipchat_creds['room'], true]
  supports :exception => true
  action :enable
  sensitive true
end.run_action(:enable)
