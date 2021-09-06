# Be sure to restart your server when you modify this file.

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'API'
end


# curl -X POST -H "Content-Type: application/json"\ -d'{"first_name":"curl","last_name":"curl","identity_number":"curl","tags":["c","u"]}'\ http://localhost:3000/api/v1/users
# curl --header "Content-Type: application/json" \
#   --request POST \
#   --data '{"first_name":"curl","last_name":"xyz","identity_number":"curl","tags":["c","u"]}' \
#   http://localhost:3000/api/v1/users
