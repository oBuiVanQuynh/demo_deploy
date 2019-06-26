require "aws-sdk"
require "fileutils"

S3_DOTENV_PATH = "ec2_setting_files/application.yml"

def error_exit msg
  STDERR.puts "[ERROR] #{msg}"
  exit 1
end

def update_env
  local_dotenv_path = "/usr/local/rails_apps/demo_deploy/shared/config/application.yml"

  s3 = Aws::S3::Resource.new region: ENV["AWS_REGION"]
  bucket = s3.bucket ENV["S3_BUCKET_NAME"]

  begin
    bucket.object(S3_DOTENV_PATH).get(response_target: local_dotenv_path)
  rescue Aws::S3::Errors::NoSuchKey
    error_exit "#{S3_DOTENV_PATH} doesn't exist in your S3 bucket."
  end
end

def upload_env
  local_dotenv_path = "/home/ec2-user/demo_deploy/config/application.yml"

  s3 = Aws::S3::Resource.new region: ENV["AWS_REGION"]
  bucket = s3.bucket ENV["S3_BUCKET_NAME"]

  begin
    bucket.object(S3_DOTENV_PATH).upload_file(local_dotenv_path)
  rescue Aws::S3::Errors::NoSuchKey
    error_exit "#{S3_DOTENV_PATH} doesn't exist in your S3 bucket."
  end
end
