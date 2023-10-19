require "sinatra"

set :bind, '0.0.0.0'

get "/dienst" do
  erb :dienst
end

get '/random_image' do
  cache_control :no_cache, :no_store, :must_revalidate
  images = Dir["/toshiba/Photo/bots_chat/*.{jpg,jpeg,png}"]
  p images.size
  random_image = images.sample
  p random_image
  send_file random_image, type: 'image/jpg', disposition: 'inline'
end

get "/darebee" do
  erb :darebee
end

get "/darebee2" do
  erb :darebee
end


require 'json'

post '/darebee_done' do
  request.body.rewind
  data = JSON.parse request.body.read
  puts "Received data: #{data}"

  Darebee.addDate(data["date"])

  content_type :json
  { status: 'success' }.to_json
end

get '/darebee/:image_name' do
  puts [:getdare,params[:image_name]]
  image_name = params[:image_name]
  send_file "darebee/#{image_name}", type: 'image/gif', disposition: 'inline'
end
