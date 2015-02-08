namespace :aws_log_archiver do

  desc "Uploads logfiles to S3"
  task :archive, [:key_prefix] => :environment do |task, args|
    AwsLogArchiver.archive!(key_prefix: args.key_prefix)
  end

end