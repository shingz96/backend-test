Rails.application.routes.draw do
  get 'posts', to: "api#list_posts"
  get 'comments', to: "api#list_comments"
end
