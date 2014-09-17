require_relative 'lib/helper'

require 'aws-sdk'
require 'dotenv/tasks'
require 'fileutils'

desc 'Upload latest tfstate'
task :upload_tfstate, [:bucket] => :aws_auth do |_, args|
  bucket = args.bucket or
    fail 'You must specify a bucket name: `rake upload_tfstate[BUCKET]`'

  s3 = AWS::S3.new
  bucket = s3.buckets[args.bucket]
  latest = bucket.objects.with_prefix('latest-').collect.first

  latest.rename_to(latest.key.gsub('latest-' ,'')) unless latest.nil?

  new_latest = IO.read('terraform.tfstate')
  bucket.objects["latest-#{Time.now.strftime("%m-%d-%y--%H-%M-%S")}.tfstate"].write(new_latest)

end

desc 'Get latest tfstate'
task :get_tfstate, [:bucket] => :aws_auth do |_, args|
  bucket = args.bucket or
    fail 'You must specify a bucket name: `rake get_tfstate[BUCKET]`'

  s3 = AWS::S3.new
  bucket = s3.buckets[args.bucket]
  latest = bucket.objects.with_prefix('latest-').collect.first
  FileUtils.mv('terraform.tfstate', 'terraform.tfstate.old') if File.exists?('terraform.tfstate')
  IO.write('terraform.tfstate', latest.read)
end

desc 'Build web image'
task :build_web_image, [:environment] => :aws_auth do |_, args|
  environment = args.environment or
    fail 'You must specify an environment type (staging or production): `rake build_web_image[ENVIRONMENT]`'

  environment.downcase!
  fail 'please supply a valid environment value (staging or production)' unless ['staging', 'production'].include?(environment)

  Helper.build_image('web', environment)
end

desc 'Build worker image'
task :build_worker_image, [:environment] => :aws_auth do |_, args|
  environment = args.environment or
    fail 'You must specify an environment type (staging or production): `rake build_worker_image[ENVIRONMENT]`'

  environment.downcase!
  fail 'please supply a valid environment value (staging or production)' unless ['staging', 'production'].include?(environment)

  Helper.build_image('worker', environment)
end

desc 'Bootstrap infrastructure using Terraform'
task :terraform => :aws_auth do
  system("terraform apply \
            -var-file infrastructure.tfvars \
            -var 'access_key=#{ENV['ACCESS_KEY_ID']}' \
            -var 'secret_key=#{ENV['SECRET_ACCESS_KEY']}'
         ")

  puts 'Tagging instances'
  web_ids = `terraform output web-ids`.strip.split(" x~x ")
  worker_ids = `terraform output worker-ids`.strip.split(" x~x ")
  web_staging_id = `terraform output web-staging-id`.strip
  worker_staging_id = `terraform output worker-staging-id`.strip

  ec2 = AWS::EC2.new
  web_ids.each { |id| ec2.instances[id].add_tag("Name", value: 'vip-sms-app-web') }
  worker_ids.each { |id| ec2.instances[id].add_tag("Name", value: 'vip-sms-app-worker') }
  ec2.instances[web_staging_id].add_tag("Name", value: 'vip-sms-app-staging-web')
  ec2.instances[worker_staging_id].add_tag("Name", value: 'vip-sms-app-staging-worker')

  puts "Creating queues (if they don't already exist)"
  Helper.create_queue('vip-sms-app-production')
  Helper.create_queue('vip-sms-app-staging')
  Helper.create_queue('vip-sms-app-development')

  puts "Creating databases (if they don't already exist)"
  Helper.create_table('vip-sms-app-users-production', 50, 50)
  Helper.create_table('vip-sms-app-users-staging', 10, 5)
  Helper.create_table('vip-sms-app-users-development', 10, 5)
end

desc 'AWS auth config'
task :aws_auth => :dotenv do
  AWS.config(
    :access_key_id => ENV['ACCESS_KEY_ID'],
    :secret_access_key => ENV['SECRET_ACCESS_KEY']
  )
end
