json.extract! petition, :id, :topic, :slug, :title, :content, :created_at, :updated_at
json.url petition_url(petition, format: :json)
