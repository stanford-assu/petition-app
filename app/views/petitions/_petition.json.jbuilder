json.extract! petition, :id, :slug, :title, :content, :created_at, :updated_at
json.url petition_url(petition, format: :json)
