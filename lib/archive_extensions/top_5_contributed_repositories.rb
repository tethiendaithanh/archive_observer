module ArchiveExtensions
  class Top5ContributedRepositories
    def self.for(github_login)
      user = GithubUser.find_by_login(github_login)

      results = GithubRepository.connection.select_all("
        SELECT github_repositories.full_name as name, count(github_pull_requests.id) as prs
        FROM github_repositories
        INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
        WHERE github_pull_requests.github_user_id = #{user.id} AND github_pull_requests.action = 'opened'
        GROUP BY github_repositories.full_name
        ORDER BY prs desc
        LIMIT 5")

      results.map do |result|
        result["prs"] = result["prs"].to_i
        result
      end
    end
  end
end
