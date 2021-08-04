apt_package 'apt-transport-https'

apt_repository 'nextdns' do
  uri 'https://repo.nextdns.io/deb'
  distribution 'stable'
  components ['main']
  key 'https://repo.nextdns.io/nextdns.gpg'
end

apt_package 'nextdns'

link '/etc/resolv.conf' do
  to '/run/systemd/resolve/resolv.conf'
  link_type :symbolic
end

replace_or_add 'DNSStub' do
  path '/etc/systemd/resolved.conf'
  pattern '#DNSStubListener=yes'
  line 'DNSStubListener=no'
end

systemd_unit 'systemd-resolved.service' do
  action [:nothing]
  subscribes :restart, 'link[/etc/resolv.conf]', :immediately
  subscribes :restart, 'replace_or_add[DNSStub]', :immediately
end

template '/etc/nextdns.conf' do
  source 'nextdns.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

systemd_unit 'nextdns.service' do
  action [:start, :enable]
  subscribes :restart, 'template[/etc/nextdns.conf]'
end
