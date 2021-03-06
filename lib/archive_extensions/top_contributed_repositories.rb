module ArchiveExtensions
  class TopContributedRepositories
    def self.pr_for(count: 5, login:, year: Time.now.year)
      user = GithubUser.find_by_login(login)

      results = GithubRepository.connection.select_all("
        SELECT github_repositories.id as id, count(github_pull_requests.id) as prs
        FROM github_repositories
        INNER JOIN github_pull_requests on github_pull_requests.github_repository_id = github_repositories.id
        WHERE github_pull_requests.github_user_id = #{user.id} AND github_pull_requests.action = 'opened' AND Extract(year from github_pull_requests.event_timestamp) = '#{year}'
        GROUP BY github_repositories.id
        ORDER BY prs desc
        LIMIT #{count}")

      ids = results.map { |res| res.fetch("id") }

      repositories = GithubRepository.where(id: ids)

      results.inject([]) do |acc,result|
        repository = repositories.detect { |repo| repo.id == result.fetch("id").to_i }
        pr_count = result.fetch("prs")
        acc << { "repo" => repository, "prs" => pr_count.to_i }
      end
    end


    def self.commit_for(count: 5, login:, year: Time.now.year)
      user = GithubUser.find_by_login(login)

      results = GithubRepository.connection.select_all("
        SELECT github_repositories.id as id, count(github_pushes.id) as commits
        FROM github_repositories
        INNER JOIN github_pushes on github_pushes.github_repository_id = github_repositories.id
        WHERE github_pushes.github_user_id = #{user.id} AND Extract(year from github_pushes.event_timestamp) = '#{year}'
        GROUP BY github_repositories.id
        ORDER BY commits desc
        LIMIT #{count}")

      ids = results.map { |res| res.fetch("id") }

      repositories = GithubRepository.where(id: ids)

      results.inject([]) do |acc,result|
        repository = repositories.detect { |repo| repo.id == result.fetch("id").to_i }
        pr_count = result.fetch("commits")
        acc << { "repo" => repository, "commits" => pr_count.to_i }
      end
    end
  end
end
