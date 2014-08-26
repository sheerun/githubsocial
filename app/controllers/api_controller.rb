class ApiController < ApplicationController

  def index
    render json: JSON.pretty_generate(
      recommendation_url: '/api'
    )
  end

  def related_repos
    repo = Repo.find_by(name: params[:name], owner: params[:owner])
    user_id = params[:user_id] ? params[:user_id].to_i : nil

    if repo.present?
      recommended = recommender.recommend(repo, user_id: user_id)
      render json: JSON.pretty_generate(recommended)
    else
      render json: []
    end
  end

  def not_found
    render json: JSON.pretty_generate(
      message: 'Not Found'
    )
  end

  private

  def recommender
    RepoRecommenderCloud.instance
  end

end
