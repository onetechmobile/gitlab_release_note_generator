require 'gitlab_release_note_generator'

describe GitlabReleaseNoteGenerator::Builder do
    it "broccoli is gross" do
        expect(GitlabReleaseNoteGenerator::Builder.testFunc("abc")).to eql("abc")
    end

    puts "Here"
end