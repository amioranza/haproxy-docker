directory '/etc/haproxy' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

directory '/etc/ssl' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

template '/etc/haproxy/haproxy.cfg' do
    source 'etc/haproxy/haproxy.cfg.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

template '/etc/ssl/cert.pem' do
    source 'etc/ssl/cert.pem.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

docker_installation_script 'Install Docker from Rancher repo' do
    repo 'main'
    script_url 'https://releases.rancher.com/install-docker/17.03.sh'
    action :create
end

docker_network 'internal' do
    subnet '192.168.88.0/24'
    gateway '192.168.88.1'
    action :create
end

docker_container 'jenkins' do
    remove_volumes true
    action :delete
end

docker_image "jenkins" do
    repo 'jenkins/jenkins'
    tag 'lts'
    action :pull
end

docker_container 'jenkins' do
    repo 'jenkins/jenkins'
    tag 'lts'
    port ['8080:8080', '50000:50000']
    privileged false
    network_mode 'internal'
    action :run_if_missing
end

docker_container 'haproxy_lb' do
    remove_volumes true
    action :delete
end

docker_image "haproxy_lb" do
    repo 'haproxy'
    tag 'alpine'
    action :pull
end


docker_container 'haproxy_lb' do
    repo 'haproxy'
    tag 'alpine'
    port ['80:80', '443:443']
    volumes ['/etc/haproxy:/usr/local/etc/haproxy', '/etc/ssl:/usr/local/etc/ssl']
    privileged false
    network_mode 'internal'
    action :run_if_missing
end