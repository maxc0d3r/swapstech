# First, we need to update our package list
execute 'apt-get-update' do
  command 'apt-get -y update'
end

# Install few packages
package 'telnet'
package 'htop'
