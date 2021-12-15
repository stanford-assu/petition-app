json.extract! user, :id, :name, :member_type, :admin, :created_at, :updated_at
json.url user_url(user, format: :json)
