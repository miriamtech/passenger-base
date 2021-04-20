require 'rake/clean'
require 'tempfile'

PROJECT_NAME = 'passenger-base'
IMAGE_NAME = "miriamtech/#{PROJECT_NAME}"
ROOT_DIR = File.expand_path('.')

if revision = ENV['GO_REVISION_GITHUB']
  BUILD_TAG =":#{revision[0,7]}"
else
  BUILD_TAG = ""
end
ENV['BUILD_TAG'] = BUILD_TAG

task :default => :test

task :build do
  build_args = [
    '--force-rm',
    "-t #{IMAGE_NAME}#{BUILD_TAG}",
  ]
  build_args << '--no-cache' unless (ENV['DOCKER_BUILD_NO_CACHE'] || '').empty?
  sh "docker build #{build_args.join(' ')} #{ROOT_DIR}"
end

task :full => [:clobber, :build]

task :test do
  sh "docker run --rm #{IMAGE_NAME}#{BUILD_TAG} /sbin/my_init -- echo 'Success'"
end

task :push do
  push_all
  push_all('latest')
end

def push_all(tag = nil)
  push(IMAGE_NAME, tag)
end

def pull_all
  pull(IMAGE_NAME)
end

def pull(image_name)
  sh "docker pull #{image_name}#{BUILD_TAG}"
end

def push(image_name, tag = nil)
  if tag
    sh "docker tag #{image_name}#{BUILD_TAG} #{image_name}:#{tag}"
    sh "docker push #{image_name}:#{tag}"
  else
    sh "docker push #{image_name}#{BUILD_TAG}"
  end
end
