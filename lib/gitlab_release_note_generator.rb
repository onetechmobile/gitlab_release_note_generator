require "gitlab_release_note_generator/version"
require "gitlab_release_note_generator/builder"

module GitlabReleaseNoteGenerator
  class Error < StandardError; end
  builder = GitlabReleaseNoteGenerator::Builder.new
  builder.main
end
