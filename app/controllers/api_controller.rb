class ApiController < ApplicationController

  def index
    current_user.starred
    render json: JSON.pretty_generate(
      recommendation_url: '/api'
    )
  end

  def related_repos
    repo = Repo.find_by(name: params[:name], owner: params[:owner])

    if repo.present?
      recommender = RepoRecommenderCloud.instance
      recommended = recommender.recommend(repo.id)
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

end
