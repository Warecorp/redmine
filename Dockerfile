FROM ruby:2.3-slim-jessie

ENV APP_ROOT="/var/www/html"

RUN set -x; \
	addgroup --gid 1000 deploy; \
	useradd -m -g deploy -s /bin/bash --uid 1000 deploy; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y curl \
	mysql-client \
	imagemagick \
	git \
	cvs \
	bzr \
	mercurial \
	darcs \
	locales \
	gcc \
	g++ \
	make \
	patch \
	libxslt1-dev \
	gettext-base \
	libc6-dev \
	zlib1g-dev \
	libxml2-dev \
	libmysqlclient-dev \
	libmagickwand-dev \
	libmagickcore-dev \
	libyaml-0-2 \
	libcurl3 \
	libssl-dev \
	uuid-dev \
	pkg-config \
	xz-utils \
	libxslt1.1 \
	libffi6 \
	zlib1g \
	gsfonts;
RUN mkdir -p /var/www/html
	# mkdir -p /mnt/configs ;\
	# mkdir -p /mnt/files ;\
	# chown -R deploy:deploy /mnt/configs ;\
	# chown -R deploy:deploy /mnt/configs


RUN mkdir /scripts

WORKDIR ${APP_ROOT}
USER deploy
ADD . /var/www/html/
# # RUN su-exec deploy gem install nokogiri -v '1.6.6.2' --no-document -- --use-system-libraries ;\
# # 	su-exec deploy gem install therubyracer -v '0.12.2' --no-document -- --use-system-libraries
# RUN bundle config build.nokogiri --use-system-libraries ;\
RUN bundle config build.therubyracer --use-system-libraries ;\
	bundle install
COPY docker/scripts/ /scripts/

USER root
RUN rm -rf /var/cache/apt

RUN rm -rf /var/www/html
RUN	mkdir /var/www/html; \
	chown -R deploy:deploy /var/www/html

COPY docker/entrypoint.sh /entrypoint.sh
USER deploy
ENTRYPOINT ["/entrypoint.sh"]
