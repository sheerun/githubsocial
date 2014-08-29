class ApiController < ApplicationController

  def index
    render json: JSON.pretty_generate(
      recommendation_url: '/api'
    )
  end

  def related_repos
    repo = Repo.find_by(name: params[:name], owner: params[:owner])
    user_id = params[:user_id] ? params[:user_id].to_i : nil
    penalize_factor = (1.5 ** [9, [1, params[:popularity].to_i].max].min).floor

    if repo.present?
      recommended = recommender.recommend(repo,
        user_id: user_id,
        penalize_factor: penalize_factor,
        force: true
      )
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
