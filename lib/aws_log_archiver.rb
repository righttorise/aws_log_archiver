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

    raise "Missing ENV['AWS_LOG_ARCHIVER_ACCESS_KEY_ID']" unless ENV['AWS_LOG_ARCHIVER_ACCESS_KEY_ID']
    raise "Missing ENV['AWS_LOG_ARCHIVER_SECRET_ACCESS_KEY']" unless ENV['AWS_LOG_ARCHIVER_SECRET_ACCESS_KEY']

    # aws-sdk v1
    AWS.config(access_key_id: ENV['AWS_LOG_ARCHIVER_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_LOG_ARCHIVER_SECRET_ACCESS_KEY'], region: 'us-east-1')
    s3 = AWS::S3.new

    # aws-sdk v2
    # Aws.config[:region] = 'us-east-1'
    # credentials = Aws::Credentials.new(ENV['AWS_LOG_ARCHIVER_ACCESS_KEY_ID'], ENV['AWS_LOG_ARCHIVER_SECRET_ACCESS_KEY'])
    # s3          = Aws::S3::Client.new(credentials: credentials)

    regex_to_logfiles = case ENV['RACK_ENV']
                        when 'test' then File.join(File.dirname(__FILE__), "../spec/logs/#{ENV['RACK_ENV']}.*")
                        else; "log/archive/#{ENV['RACK_ENV']}.*"
                        end

    logfiles     = Dir.glob(regex_to_logfiles)
    logfile_path = logfiles.sort.last

    log_file = File.read(logfile_path)
    key      = File.basename(logfile_path.gsub(/#{ENV['RACK_ENV']}/, key_prefix))
    bucket   = 'ge-shrub/log/rtr'
    
    # aws-sdk v1
    object = s3.buckets[bucket].objects[key]
    object.write(log_file)

    # aws-sdk v2
    # s3.put_object bucket: bucket, key: key, body: log_file
    
    puts "Put #{logfile_path} as #{key} in #{bucket}"
  end

end
