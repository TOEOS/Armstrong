json.articles @articles
json.articles do
  json.partial! 'article', collection: @articles, as: :article
end
