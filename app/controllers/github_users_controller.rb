class GithubUsersController < ApplicationController
  def top
    @top_developers = ArchiveExtensions::TopActiveDevelopers.for(count: params[:count].to_i)
  end

  def profile
    @user = GithubUser.find_by_login(params[:login])
  end
end
