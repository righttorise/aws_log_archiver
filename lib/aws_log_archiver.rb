require 'aws-sdk'
require 'aws_log_archiver/version'
require 'aws_log_archiver/railtie' if defined?(Rails)

module AwsLogArchiver

  # expects log files folder to look like this:
  #
  # -rw-rw-r-- 1 root   app_writers    364 Feb  6 21:01 nginx_error.log.2015-02-07.gz
  # -rw-rw-r-- 1 root   app_writers    240 Feb  7 22:01 nginx_error.log.2015-02-08.gz
  # -rw-rw---- 1 ubuntu app_writers 269914 Feb  7 00:04 production.log.2015-02-07.gz
  # -rw-rw---- 1 ubuntu app_writers 154000 Feb  8 00:02 production.log.2015-02-08.gz


  def self.archive!(args = {})
    key_prefix        = args[:key_prefix] || raise("Missing key_prefix")
    regex_to_logfiles = args[:regex_to_logfiles] || raise("Missing regex_to_logfiles")

    raise "Missing ENV['AWS_LOG_ARCHIVER_ACCESS_KEY_ID']" unless ENV['AWS_LOG_ARCHIVER_ACCESS_KEY_ID']
    raise "Missing ENV['AWS_LOG_ARCHIVER_SECRET_ACCESS_KEY']" unless ENV['AWS_LOG_ARCHIVER_SECRET_ACCESS_KEY']

    Aws.config[:region] = 'us-east-1'

    credentials = Aws::Credentials.new(ENV['AWS_LOG_ARCHIVER_ACCESS_KEY_ID'], ENV['AWS_LOG_ARCHIVER_SECRET_ACCESS_KEY'])
    s3          = Aws::S3::Client.new(credentials: credentials)

    logfiles     = Dir.glob(regex_to_logfiles)
    logfile_path = logfiles.sort.last

    log_file = File.read(logfile_path)
    key      = File.basename(logfile_path.gsub(/production/, key_prefix))
    bucket   = 'ge-shrub/log/rtr'
    
    s3.put_object bucket: bucket, key: key, body: log_file
    puts "Put #{logfile_path} as #{key} in #{bucket}"
  end

end
