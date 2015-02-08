namespace :aws_log_archiver do

  desc "Uploads logfiles to S3"
  task :archive, [:key_prefix, :regex_to_logfiles] do |task, args|
    AwsLogArchiver.archive!(key_prefix: args.key_prefix, regex_to_logfiles: args.regex_to_logfiles)
  end

end