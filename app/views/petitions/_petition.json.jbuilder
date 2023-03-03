json.extract! petition, :id, :topic, :slug, :title, :content, :user, :created_at, :updated_at

json.user petition.user.id

json.signees do
    json.array! petition.signees.collect { |u| u.id }
  end

json.url petition_url(petition, format: :json)
