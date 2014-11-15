module Overcommit
  module Hook
    module PreCommit
      class Rspec < Base
        def run
          files = applicable_files.select { |f| f.match(%r{/app/|/lib/}) }
                  .map { |f| f.sub(%r{/app/|/lib/}, '/spec/').sub(/\.rb$/, '_spec.rb') }
                  .select { |f| File.exist?(f) }
          return :pass if files.empty?
          result = execute(
            %W(#{config['overwritten_executable'] ? config['overwritten_executable'] : executable}) + files
          )
          return :pass if result.success?
          [:fail, result.stdout.chomp.split("\n").grep(/rspec/).join("\n") + result.stderr.chomp]
        end
      end
    end
  end
end
