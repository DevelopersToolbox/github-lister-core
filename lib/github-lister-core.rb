#
# Require the external gems
#
require 'json'
require 'octokit'
require 'parallel'

#
# Require the internal components
#
require_relative 'github-lister-core/client'
require_relative 'github-lister-core/errors'
require_relative 'github-lister-core/languages'
require_relative 'github-lister-core/organisations'
require_relative 'github-lister-core/preview'
require_relative 'github-lister-core/releases'
require_relative 'github-lister-core/repos'
require_relative 'github-lister-core/topics'
require_relative 'github-lister-core/users'
require_relative 'github-lister-core/utils'
require_relative 'github-lister-core/version'
require_relative 'github-lister-core/wrapper'

#
# This is the main class
#
# This class smells of :reek:RepeatedConditional
class GithubListerCore
    class << self
        #
        # stuff goes here
        #
        def user_repos(options = {})
            validate_options(options)
            client = init_client(options)
            users = get_user_list(client, options)

            if flag_set?(options, :use_slugs)
                user_repo_slugs_private(client, options, users)
            else
                user_repos_private(client, options, users)
            end
        end

        #
        # Get a list of repos got a given organisation
        # If the user is authenticated and a member of the org it will list private + public
        #
        def org_repos(options = {})
            validate_options(options)
            client = init_client(options)
            orgs = get_org_list(options)

            if flag_set?(options, :use_slugs)
                org_repo_slugs_private(client, orgs).to_json
            else
                org_repos_private(client, options, orgs).to_json
            end
        end

        #
        # Get a list of repos for ALL organisations that a user is a member of
        # If the user is authenticated and a member of the org it will list private + public
        #
        def org_members_repos(options = {})
            validate_options(options)
            client = init_client(options)
            users = get_user_list(client, options)

            if flag_set?(options, :use_slugs)
                org_members_repo_slugs_private(client, users).to_json
            else
                org_members_repos_private(client, options, users).to_json
            end
        end

        #
        # Generate a slub list of repos for all organisations that a user is a member of
        #
        def all_repos(options = {})
            validate_options(options)
            client = init_client(options)
            user = get_user_list(client, options)

            if flag_set?(options, :use_slugs)
                all_repo_slugs_private(client, user).to_json
            else
                all_repos_private(client, options, user).to_json
            end
        end

        #
        # These are the public wrappers which return json encoded objects.
        #

        def org_membership(options = {})
            validate_options(options)
            client = init_client(options)
            users = get_user_list(client, options)

            if flag_set?(options, :use_slugs)
                org_membership_slugs_private(client, users).to_json
            else
                org_membership_private(client, users).to_json
            end
        end
    end
end

#
# Add an alias because the name is long
#
GLC = GithubListerCore
