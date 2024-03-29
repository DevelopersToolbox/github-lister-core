#
# Pull information specific to organisations (org repos are in repos.rb)
#
class GithubListerCore
    class << self
        #
        # Everything below here is private
        #

        private

        # rubocop:disable Metrics/MethodLength
        def get_org_list(options)
            org_param = get_option(options, [:org_name, :org])

            raise MissingOrganisationError.new unless org_param

            case org_param
            when Array
                orgs = org_param
            when String
                orgs = convert_to_array(org_param)
            else
                raise InvalidParameterError.new
            end
            orgs
        end
        # rubocop:enable Metrics/MethodLength

        #
        # Get a list of organisations that a user is a member of
        #
        # This method smells of :reek:DuplicateMethodCall

        def org_repos_from_github(client, org)
            function_wrapper(client, 'organization_repositories', org)
        end

        def org_repos_in_parallel(client, orgs)
            (repos ||= []) << Parallel.map(orgs, :in_threads => orgs.count) { |org| org_repos_from_github(client, org) }
            clean_from_parallel(repos, :full_name)
        end

        # Get the org list for a list of users
        def org_membership_from_github(client, org)
            function_wrapper(client, 'organizations', org)
        end

        def org_membership_in_parallel(client, users)
            (orgs ||= []) << Parallel.map(users, :in_threads => users.count) { |user| org_membership_from_github(client, user) }
            clean_from_parallel(orgs, :login)
        end

        def org_membership_private(client, users)
            org_membership_in_parallel(client, users)
        end

        def org_membership_slugs_private(client, users)
            org_membership_in_parallel(client, users).map { |hash| hash[:login] }.compact
        end
    end
end
