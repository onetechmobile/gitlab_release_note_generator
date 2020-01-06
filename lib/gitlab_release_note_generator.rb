require "gitlab_release_note_generator/version"
require "gitlab_release_note_generator/builder"

module GitlabReleaseNoteGenerator
  class Error < StandardError; end
  builder = GitlabReleaseNoteGenerator::Builder.new
  host_name = ARGV[0]
  private_token = ARGV[1]
  project_id = ARGV[2] 

  builder.main
end
