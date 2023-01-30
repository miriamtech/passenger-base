require 'rake/clean'
require 'tempfile'

UPSTREAM_VERSION_1 = '1.0.19'
UPSTREAM_VERSION_2 = '2.5.0'

VARIANTS = {
  'miriamtech/passenger-ruby25': { from: "phusion/passenger-ruby25:#{UPSTREAM_VERSION_1}", rubygems_version: '3.3.26' },
  'miriamtech/passenger-ruby27': { from: "phusion/passenger-ruby27:#{UPSTREAM_VERSION_2}" },
  'miriamtech/passenger-ruby30': { from: "phusion/passenger-ruby30:#{UPSTREAM_VERSION_2}" },
  'miriamtech/passenger-ruby31': { from: "phusion/passenger-ruby31:#{UPSTREAM_VERSION_2}" },
  'miriamtech/passenger-ruby32': { from: "phusion/passenger-ruby32:#{UPSTREAM_VERSION_2}" },
}
ROOT_DIR = File.expand_path('.')
BUILD_TAG = ENV['GO_REVISION_SOURCE'] ? ":#{ENV['GO_REVISION_SOURCE'].slice(0, 7)}" : ''

task :default => :test

task :build do
  VARIANTS.each do |image_name, params|
    build_args = [
      '--force-rm',
      "--build-arg PASSENGER_UPSTREAM=#{params[:from]}",
      "-t #{image_name}#{BUILD_TAG}",
    ]
    build_args << "--build-arg RUBYGEMS_VERSION=#{params[:rubygems_version]}" if params[:rubygems_version]
    build_args << '--no-cache' if !ENV.fetch('DOCKER_BUILD_NO_CACHE', '').empty? || ENV['GO_TRIGGER_USER'] == 'timer'
    sh "docker build #{build_args.join(' ')} #{ROOT_DIR}"
  end
end

task :full => [:clobber, :build]

task :test do
  VARIANTS.each_key do |image_name|
    sh "docker run --rm #{image_name}#{BUILD_TAG} /sbin/my_init -- ruby --version"
  end
end

task :push do
  push_all
  push_all('latest')
end

def push_all(tag = nil)
  VARIANTS.each_key do |image_name|
    push(image_name, tag)
  end
end

def push(image_name, tag = nil)
  if tag
    sh "docker tag #{image_name}#{BUILD_TAG} #{image_name}:#{tag}"
    sh "docker push #{image_name}:#{tag}"
  else
    sh "docker push #{image_name}#{BUILD_TAG}"
  end
end
