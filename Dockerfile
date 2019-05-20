FROM php:7.1.29-apache-stretch

#
# Temporary fix for slow CDN-based mirrors
#
RUN rm -rf /etc/apt/sources.list
COPY debian/stretch.list /etc/apt/sources.list.d/stretch.list

#
# install various, useful packages
#
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  git \
  libmagickwand-dev \
  lsof \
  unzip \
  vim

#
# Prepare working environment
#
WORKDIR /usr/local/bin

#
# Install composer
#
RUN curl -s https://getcomposer.org/installer | php
RUN chmod 755 /usr/local/bin/composer.phar
RUN chmod 770 /var/www/html
RUN chown -R www-data:www-data /var/www

#
# Retrieve neos
#
RUN php composer.phar create-project neos/neos-base-distribution /var/www/html/Neos

#
# Install PHP extensions
#
RUN docker-php-ext-install \
	pdo_mysql
RUN pecl install \
	imagick
RUN docker-php-ext-enable \
	imagick

#
# Ship configuration files
#
COPY configs/php.ini "$PHP_INI_DIR/php.ini"
COPY configs/Settings.yaml /var/www/html/Neos/Configuration/Settings.yaml
COPY configs/000-default.conf /etc/apache2/sites-enabled/000-default.conf

#
# Enable mod_rewrite
#
RUN a2enmod rewrite

#
# Adapt file permissions
#
RUN chown -R www-data:www-data /var/www/html/Neos

#
# Wrap new entrypoint, so we can run pre-entrypoint stuff
#
COPY configs/docker-php-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-php-entrypoint"]

EXPOSE 80
CMD ["apache2-foreground"]
