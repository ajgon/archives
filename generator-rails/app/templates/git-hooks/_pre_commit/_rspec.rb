module Overcommit
  module Hook
    module PreCommit
      class Rspec < Base
        def run
          files = applicable_files.select { |f| f.match(%r{/app/|/lib/}) }
          .map { |f| f.sub(%r{/app/|/lib/}, '/spec/').sub(/\.rb$/, '_spec.rb') }
          result = execute(%W(#{executable} --fail-fast) + files)
          return :pass if result.success?
          [:fail, result.stdout.chomp.split("\n").grep(/rspec/).join("\n")]
        end
      end
    end
  end
end