json.array! @petitions do |petition|

  json.id petition.id
  json.topic petition.topic
  json.slug petition.slug
  json.title petition.title
  json.content petition.content.to_plain_text()
  json.user petition.user.id

  json.signees do
    json.array! petition.signees.collect { |u| u.id }
  end

end