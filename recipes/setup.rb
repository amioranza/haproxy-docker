# Create haproxy config directory on the docker host
directory '/etc/haproxy' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

# Create ssl certificates directory on the docker host
directory '/etc/ssl' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

# Create the haproxy.cfg file based on the template attached to the cookbook
template '/etc/haproxy/haproxy.cfg' do
    source 'etc/haproxy/haproxy.cfg.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

# Create the cert.pem file based on the template attached to the cookbook
template '/etc/ssl/cert.pem' do
    source 'etc/ssl/cert.pem.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

# Install docker release form Rancher, basically the same from the official repo
docker_installation_script 'Install Docker from Rancher repo' do
    repo 'main'
    script_url 'https://releases.rancher.com/install-docker/17.03.sh'
    action :create
end

# Create a network to plug the containers, using custom networks does not require links between containers
docker_network 'internal' do
    subnet '192.168.88.0/24'
    gateway '192.168.88.1'
    action :create
end

# Delete existing container to deploy again
docker_container 'jenkins' do
    remove_volumes true
    action :delete
end

# Pull the image from docker hub
docker_image "jenkins" do
    repo 'jenkins/jenkins'
    tag 'lts'
    action :pull
end

# Deploy jenkins CI to test the setup, can be any other image
docker_container 'jenkins' do
    repo 'jenkins/jenkins'
    tag 'lts'
    port ['8080:8080', '50000:50000']
    privileged false
    network_mode 'internal'
    action :run_if_missing
end

# Delete existing container to deploy again
docker_container 'haproxy_lb' do
    remove_volumes true
    action :delete
end

# Pull the image from docker hub
docker_image "haproxy_lb" do
    repo 'haproxy'
    tag 'alpine'
    action :pull
end

# Deploy haproxy alpine flavor to keep everything as slim as possible
docker_container 'haproxy_lb' do
    repo 'haproxy'
    tag 'alpine'
    port ['80:80', '443:443','9000:9000']
    volumes ['/etc/haproxy:/usr/local/etc/haproxy', '/etc/ssl:/usr/local/etc/ssl']
    privileged false
    network_mode 'internal'
    action :run_if_missing
end