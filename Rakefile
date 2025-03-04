require 'rake/clean'
require 'tempfile'

LEGACY_UPSTREAM_VERSION = '2.6.2'
UPSTREAM_VERSION = '3.1.2'

VARIANTS = {
  # Ruby 2.5 went EOL in April 2021. Support was dropped in Passenger 2.0 and Rubygems 3.4.0
  'miriamtech/passenger-ruby25': { from: "phusion/passenger-ruby25:1.0.19", rubygems_version: '3.3.26' },

  # Ruby 2.7 went EOL on March 30, 2023. Support was dropped in Passenger 2.6.0 and Rubygems 3.5.0
  'miriamtech/passenger-ruby27': { from: "phusion/passenger-ruby27:2.5.1", rubygems_version: '3.4.22' },

  # Current versions
  'miriamtech/passenger-ruby30': { from: "phusion/passenger-ruby30:#{LEGACY_UPSTREAM_VERSION}" },
  'miriamtech/passenger-ruby31': { from: "phusion/passenger-ruby31:#{LEGACY_UPSTREAM_VERSION}" },
  'miriamtech/passenger-ruby32': { from: "phusion/passenger-ruby32:#{LEGACY_UPSTREAM_VERSION}" },
  'miriamtech/passenger-ruby33': { from: "phusion/passenger-ruby33:#{LEGACY_UPSTREAM_VERSION}" },
  'miriamtech/passenger-ruby34': { from: "phusion/passenger-ruby34:#{UPSTREAM_VERSION}" },
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
