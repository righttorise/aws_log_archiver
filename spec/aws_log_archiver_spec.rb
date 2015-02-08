ENV['AWS_LOG_ARCHIVER_ACCESS_KEY_ID']     = '123'
ENV['AWS_LOG_ARCHIVER_SECRET_ACCESS_KEY'] = '456'

require 'aws_log_archiver'
require 'webmock/rspec'

RSpec.describe AwsLogArchiver do

  describe '.archive!' do
    before do
      stub_request(:any, /amazon/).to_return(status: 200)
    end
    it do
      AwsLogArchiver.archive!(key_prefix: 'test', regex_to_logfiles: File.join(File.dirname(__FILE__), '../spec/logs/production.*'))
    end
  end

end