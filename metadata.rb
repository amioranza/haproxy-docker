name 'haproxy-docker'
maintainer 'A. Mioranza'
maintainer_email 'amioranza@mdcnet.ninja'
license 'CC'
description 'Installs/Configures haproxy-docker'
long_description 'Installs/Configures haproxy-docker'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'docker', '~> 3.0'