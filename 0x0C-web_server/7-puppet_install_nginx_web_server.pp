# Puppet manifest to perform all previous tasks
# 1. send apt update to puppet agent
# 2. make sure nginx is installed
# 3. make sure home page file is present
# 4. make sure custom 404 page is setup
# 5. update nginx config.
# 6. restart nginx server
exec { 'Update the apt repository':
  command => 'apt update',
  path    => '/usr/bin:/usr/sbin:/bin'
}

package { 'The web server':
  ensure          => installed,
  name            => 'nginx',
  provider        => 'apt',
  install_options => ['-y']
}

file { 'The home page':
  ensure  => file,
  path    => '/var/www/html/index.html',
  mode    => '0744',
  owner   => 'www-data',
  content => "Hello World!\n"
}

file { 'The 404 page':
  ensure  => file,
  path    => '/var/www/error/custom_404.html',
  mode    => '0744',
  owner   => 'www-data',
  content => "Ceci n'est pas une page\n"
}

file { 'Nginx server config file':
  ensure  => file,
  path    => '/etc/nginx/sites-enabled/default',
  mode    => '0744',
  owner   => 'www-data',
  content =>
"server {
	listen 80 default_server;
	listen [::]:80 default_server;
	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;
	server_name _;
	location / {
		try_files \$uri \$uri/ =404;
	}
	if (\$request_filename ~ redirect_me){
		rewrite ^ https://sketchfab.com/bluepeno/models permanent;
	}
	error_page 404 /404.html;
	location = /404.html {
		root /var/www/error/;
		internal;
	}
}"
}

exec { 'Start the server':
  command => 'service nginx restart',
  path    => '/usr/bin:/usr/sbin:/bin'
}
