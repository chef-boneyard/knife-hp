#
# Author:: Matt Ray (<matt@getchef.com>)
# Copyright:: Copyright (c) 2012-2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/hp_base'

class Chef
  class Knife
    class HpServerCreate < Knife

      include Knife::HpBase

      deps do
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife hp server create (options)"

      option :flavor,
      :short => "-f FLAVOR_ID",
      :long => "--flavor FLAVOR_ID",
      :description => "The HP Cloud Size for the server",
      :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f }

      option :image,
      :short => "-I IMAGE_ID",
      :long => "--image IMAGE_ID",
      :description => "The HP Cloud Install Image ID for the server",
      :proc => Proc.new { |i| Chef::Config[:knife][:image] = i }

      option :security_groups,
      :short => "-G X,Y,Z",
      :long => "--groups X,Y,Z",
      :description => "The HP Cloud Security Group(s) for this server",
      :default => ["default"],
      :proc => Proc.new { |groups| groups.split(',') }

      option :ssh_key_name,
      :short => "-S KEY",
      :long => "--ssh-key KEY",
      :description => "The HP Cloud Key Pair ID",
      :proc => Proc.new { |key| Chef::Config[:knife][:hp_ssh_key_id] = key }

      option :availability_zone,
      :short => "-Z Zone",
      :long => "--hp-zone Zone",
      :default => "az1",
      :description => "Your HP Cloud Availability Zone within your Region (az1/az2/az3)",
      :proc => Proc.new { |key| Chef::Config[:knife][:hp_avl_zone] = key }

      option :chef_node_name,
      :short => "-N NAME",
      :long => "--node-name NAME",
      :description => "The Chef node name for your new node"

      option :ssh_user,
      :short => "-x USERNAME",
      :long => "--ssh-user USERNAME",
      :description => "The ssh username",
      :default => "root"

      option :ssh_password,
      :short => "-P PASSWORD",
      :long => "--ssh-password PASSWORD",
      :description => "The ssh password"

      option :identity_file,
      :short => "-i IDENTITY_FILE",
      :long => "--identity-file IDENTITY_FILE",
      :description => "The SSH identity file used for authentication"

      option :prerelease,
      :long => "--prerelease",
      :description => "Install the pre-release chef gems"

      option :bootstrap_version,
      :long => "--bootstrap-version VERSION",
      :description => "The version of Chef to install",
      :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_version] = v }

      option :bootstrap_proxy,
      :long => "--bootstrap-proxy PROXY_URL",
      :description => "The proxy server for the node being bootstrapped",
      :proc => Proc.new { |p| Chef::Config[:knife][:bootstrap_proxy] = p }

      option :distro,
      :short => "-d DISTRO",
      :long => "--distro DISTRO",
      :description => "Bootstrap a distro using a template; default is 'chef-full'",
      :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
      :default => "chef-full"

      option :template_file,
      :long => "--template-file TEMPLATE",
      :description => "Full path to location of template to use",
      :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
      :default => false

      option :run_list,
      :short => "-r RUN_LIST",
      :long => "--run-list RUN_LIST",
      :description => "Comma separated list of roles/recipes to apply",
      :proc => lambda { |o| o.split(/[\s,]+/) },
      :default => []

      option :host_key_verify,
      :long => "--[no-]host-key-verify",
      :description => "Verify host key, enabled by default",
      :boolean => true,
      :default => true

      option :networks,
      :long => "--networks NETWORK_1,NETWORK_2,NETWORK_3",
      :description => "Comma separated list of the name(s) of the network(s) for the server to attach",
      :proc => Proc.new { |networks| networks.split(',') }

      option :floating_ip,
      :short => "-a [IP]",
      :long => "--floating-ip [IP]",
      :default => "-1",
      :description => "Request to associate a floating IP address to server. Assumes IPs have been allocated to the project. Specifying IP is optional."

      option :bootstrap_network,
      :long => '--bootstrap-network NAME',
      :description => "Specify network for bootstrapping."

      def tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, 22)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
      rescue Errno::ETIMEDOUT
        false
      rescue Errno::EPERM
        false
      rescue Errno::ECONNREFUSED
        sleep 2
        false
      rescue Errno::EHOSTUNREACH
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end

      def run
        $stdout.sync = true

        validate!

        #servers require a name, generate one if not passed
        node_name = get_node_name(config[:chef_node_name])

        Chef::Log.debug("Name #{node_name}")
        Chef::Log.debug("Flavor #{locate_config_value(:flavor)}")
        Chef::Log.debug("Image #{locate_config_value(:image)}")
        Chef::Log.debug("Group(s) #{config[:security_groups]}")
        Chef::Log.debug("Availability Zone #{locate_config_value(:availability_zone)}")
        Chef::Log.debug("Requested Floating IP #{locate_config_value(:floating_ip)}")
        Chef::Log.debug("Key Pair #{Chef::Config[:knife][:hp_ssh_key_id]}")

        server_def = {
          :name => node_name,
          :flavor_id => locate_config_value(:flavor),
          :image_id => locate_config_value(:image),
          :security_groups => config[:security_groups],
          :availability_zone => locate_config_value(:availability_zone),
          :key_name => Chef::Config[:knife][:hp_ssh_key_id]
        }
        unless locate_config_value(:networks).nil?
          server_def[:nics] = locate_config_value(:networks).map do |nic|
            nic_id = { 'net_id' => nic }
            nic_id
          end
        end
        Chef::Log.debug("server_def is: #{server_def}")

        server = connection.servers.create(server_def)

        msg_pair("Instance Name", server.name)
        msg_pair("Instance ID", server.id)
        msg_pair("Availability zone", server.availability_zone)

        print "\n#{ui.color("Waiting for server", :magenta)}"

        # wait for it to be ready to do stuff
        server.wait_for { print "."; ready? }

        puts("\n")

        msg_pair("Flavor", server.flavor.name)
        msg_pair("Image", server.image.name)
        msg_pair("Security Group(s)", server.security_groups.collect {|x| x['name']}.join(", "))
        msg_pair("SSH Key Pair", server.key_name)

        Chef::Log.debug("Addresses #{server.addresses}")

        floating_address = locate_config_value(:floating_ip)
        Chef::Log.debug("Floating IP Address requested #{floating_address}")
        unless (floating_address == '-1') # no floating IP requested
          addresses = connection.addresses
          # floating requested without value
          if floating_address.nil?
            free_floating = addresses.find_index { |a| a.fixed_ip.nil? }
            if free_floating.nil? # no free floating IP found
              ui.error("Unable to assign a Floating IP from allocated IPs.")
              exit 1
            else
              floating_address = addresses[free_floating].ip
            end
          end
          connection.associate_address(server.id, floating_address)
          msg_pair("Floating IP Address", floating_address)
        end

        bootstrap_network = locate_config_value(:bootstrap_network)

        unless bootstrap_network.nil?
          Chef::Log.debug("Bootstrap specified network: #{bootstrap_network}")
          bootstrap_ip_address = primary_network_ip_address(server.addresses, bootstrap_network)
        else
          if (floating_address == '-1') # no float requested
            Chef::Log.debug("Bootstrap first network: #{server.addresses.first[0]}")
            bootstrap_ip_address = server.addresses.first[1][0]['addr']
          else
            Chef::Log.debug("Bootstrap floating IP address: #{floating_address}")
            bootstrap_ip_address = floating_address
          end
        end

        print "\n#{ui.color("Waiting for sshd on #{bootstrap_ip_address}", :magenta)}"

        # hack to ensure the nodes have had time to spin up
        print(".")
        sleep 30
        print(".")

        print(".") until tcp_test_ssh(bootstrap_ip_address) {
          sleep @initial_sleep_delay ||= 10
          puts("done")
        }

        bootstrap_for_node(server, bootstrap_ip_address).run

        puts "\n"
        msg_pair("Instance ID", server.id)
        msg_pair("Instance Name", server.name)
        msg_pair("Flavor", server.flavor.name)
        msg_pair("Image", server.image.name)
        msg_pair("Security Group(s)", server.security_groups.collect {|x| x['name']}.join(", "))
        msg_pair("SSH Key Pair", server.key_name)
        server.addresses.each do |name,addr|
          msg_pair("Network", name)
          msg_pair("  IP Address", addr[0]['addr'])
        end
        msg_pair("Environment", config[:environment] || '_default')
        msg_pair("Run List", config[:run_list].join(', '))
      end

      def bootstrap_for_node(server, bootstrap_ip_address)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = bootstrap_ip_address
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] = config[:ssh_user]
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:host_key_verify] = config[:host_key_verify]
        bootstrap.config[:chef_node_name] = server.name
        bootstrap.config[:prerelease] = config[:prerelease]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:bootstrap_proxy] = locate_config_value(:bootstrap_proxy)
        bootstrap.config[:distro] = locate_config_value(:distro)
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = config[:environment]
        # let ohai know we're using OpenStack
        Chef::Config[:knife][:hints] ||= {}
        Chef::Config[:knife][:hints]['hp'] ||= {}
        bootstrap
      end

      def flavor
        @flavor ||= connection.flavors.get(locate_config_value(:flavor))
      end

      def image
        @image ||= connection.images.get(locate_config_value(:image))
      end

      def validate!

        super([:image, :flavor, :hp_access_key, :hp_secret_key, :hp_tenant_id])

        if flavor.nil?
          ui.error("You have not provided a valid flavor ID. Please note the options for this value are -f or --flavor.")
          exit 1
        end

        if image.nil?
          ui.error("You have not provided a valid image ID. Please note the options for this value are -I or --image.")
          exit 1
        end
      end

      #generate a random name if chef_node_name is empty
      def get_node_name(chef_node_name)
        return chef_node_name unless chef_node_name.nil?
        #lazy uuids
        chef_node_name = "hp-"+rand.to_s.split('.')[1]
      end
    end
  end
end
