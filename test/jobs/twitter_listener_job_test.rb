require 'test_helper'

class TwitterListenerJobTest < ActiveJob::TestCase
	test "the truth" do
		TwitterListenerJob.perform_now()
	end
end
