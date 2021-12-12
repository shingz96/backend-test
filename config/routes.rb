Rails.application.routes.draw do
  get 'posts', to: "api#list_posts"
end
