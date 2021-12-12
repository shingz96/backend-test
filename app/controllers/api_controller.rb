class ApiController < ApplicationController
  require 'net/http'

  def list_posts
    render json: top_posts
  end

  def list_comments
    render json: search(comments, params[:q])
  end

  private

  def search(records, keyword)
    return records unless keyword.present?

    matched = []
    records.each do |record|
      record.keys.each do |key|
        if record[key].to_s == keyword
          matched << record
          break
        end
      end
    end
    matched
  end

  def comments
    @_comments ||= Array.wrap(http_get("https://jsonplaceholder.typicode.com/comments"))
  end

  def comments_count_by_post_id(post_id)
    @_comments_count_by_post_id ||= comments.each_with_object(Hash.new) { |comment, hash| hash[comment['postId']] = hash[comment['postId']].to_i + 1 }
    @_comments_count_by_post_id.dig(post_id)
  end

  def top_posts
    posts = []
    records = Array.wrap(http_get('https://jsonplaceholder.typicode.com/posts'))
    records.each do |post|
      posts.push(
        {
          post_id: post['id'],
          post_title: post['title'],
          post_body: post['body'],
          total_number_of_comments: comments_count_by_post_id(post['id']).to_i
        }
      )
    end

    posts.sort_by{ |post| [post[:total_number_of_comments] * -1, post[:post_id]] }
  end

  def http_get(url)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body)
  rescue StandardError => e
    puts e.message
    nil
  end
end
