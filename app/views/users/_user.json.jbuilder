json.extract! user, :id, :name, :member_type, :coterm, :admin, :created_at, :updated_at
json.url user_url(user, format: :json)
