class ApiController < ApplicationController

  layout false

  instrument_action :related_repos

  def index
    head :ok
  end

  def related_repos
    render json: cached_related_repos
  end

  def not_found
    render json: JSON.pretty_generate(
      message: 'Not Found'
    )
  end

  private

  def cached_related_repos
    Rails.cache.fetch(request.url, expires_in: 30.minutes) do
      repo = Repo.find_by(name: params[:name], owner: params[:owner])
      user_id = params[:user_id] ? params[:user_id].to_i : nil
      penalize_factor = (1.5 ** [9, [1, params[:popularity].to_i].max].min).floor

      if repo.present?
        recommended = recommender.recommend(repo,
          user_id: user_id,
          penalize_factor: penalize_factor
        )

        JSON.pretty_generate(recommended)
      else
        JSON.pretty_generate([])
      end
    end
  end

  def recommender
    RepoRecommenderCloud.instance
  end

end
