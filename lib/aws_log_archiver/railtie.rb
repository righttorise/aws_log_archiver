module AwsLogArchiver
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'aws_log_archiver/tasks/aws_log_archiver.rake'
    end
  end
end