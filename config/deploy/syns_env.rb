require "aws-sdk"
require "fileutils"

S3_DOTENV_PATH = "ec2_setting_files/application.yml"
LOCAL_DOTENV_PATH = "/home/ec2-user/demo_deploy/config/application.yml"

def error_exit msg
  STDERR.puts "[ERROR] #{msg}"
  exit 1
end

def update_env

  s3 = Aws::S3::Resource.new region: ENV["AWS_REGION"]
  bucket = s3.bucket ENV["S3_BUCKET_NAME"]

  begin
    response = bucket.object(S3_DOTENV_PATH).get(response_target: LOCAL_DOTENV_PATH)
  rescue Aws::S3::Errors::NoSuchKey
    error_exit "#{S3_DOTENV_PATH} doesn't exist in your S3 bucket."
  end
end

def upload_env
  s3 = Aws::S3::Resource.new region: ENV["AWS_REGION"]
  bucket = s3.bucket ENV["S3_BUCKET_NAME"]

  begin
    bucket.object(S3_DOTENV_PATH).upload_file(LOCAL_DOTENV_PATH)
  rescue Aws::S3::Errors::NoSuchKey
    error_exit "#{S3_DOTENV_PATH} doesn't exist in your S3 bucket."
  end
end
