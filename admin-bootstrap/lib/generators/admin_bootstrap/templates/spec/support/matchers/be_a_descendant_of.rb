RSpec::Matchers.define :be_a_descendant_of do |expected|
  match do |actual|
    actual.ancestors.include?(expected)
  end

  failure_message_for_should do |actual|
    "expected that #{actual.to_s} would be a descendant of #{expected.to_s}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not be a descendant of #{expected.to_s}"
  end

  description do
    "be a descendant of #{expected.to_s}"
  end
end