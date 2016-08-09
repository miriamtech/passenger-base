FROM phusion/passenger-ruby23:0.9.19
CMD ["/sbin/my_init"]

RUN apt-get update \
    && apt-get -y purge openssh-server openssh-sftp-server \
    && apt-get -y upgrade -o Dpkg::Options::="--force-confold" \
    && apt-get clean

# Install latest rubygems and bundler
RUN gem update --system \
    && gem uninstall rubygems-update \
    && gem install bundler \
    && gem pristine --all

# Setup Nginx and Passenger
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

# Precompile Passenger native extension for faster cold startup
RUN setuser app ruby -S passenger-config build-native-support

# Enable unattended-upgrades
RUN echo unattended-upgrades unattended-upgrades/enable_auto_updates select true | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install unattended-upgrades \
    && apt-get -y install update-notifier-common
ADD scripts/cron-restart.sh /etc/cron.daily/restart-nginx-if-necessary

# Workarounds to allow nginx upgrades on the fly
RUN dpkg-divert --add --rename --divert /usr/sbin/nginx.real /usr/sbin/nginx \
    && dpkg-divert --add --divert /etc/init.d/nginx.orig /etc/init.d/nginx \
    && sed -i.orig -e 's/\/usr\/sbin\/nginx$/\/usr\/sbin\/nginx.real/' -e 's/NAME\=nginx$/NAME\=nginx.real/' /etc/service/nginx/run /etc/init.d/nginx
ADD scripts/policy-rc.d.rb /usr/sbin/policy-rc.d
