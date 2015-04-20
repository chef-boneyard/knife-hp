Knife HP
========

# NOTE: this gem has been depricated in favor for [knife-openstack](https://github.com/chef/knife-openstack). There is a 1 to 1 support with this gem and it's commands to the `knife-openstack`.

This is the official Chef Knife plugin for HP Helion Public Cloud Compute. This plugin gives knife the ability to create, bootstrap and manage instances in the HP Public Cloud 13.5 and later. You may need to go to https://horizon.hpcloud.com and enable Compute under "Activate Services" for the Region you wish to use. (You still have to activate the service) To properly configure your networks (include a router for external access), please refer to https://docs.hpcloud.com/hpcloudconsole.

If you are still using the older version of the API, you may need version 0.3.1 of this plugin, HP's migration and upgrade instructions are here: https://docs.hpcloud.com/migration-overview-reference/.

Please refer to the [CHANGELOG](CHANGELOG.md) for version history.

# Installation #

Be sure you are running the latest version Chef. Versions earlier than 0.10.0 don't support plugins:

    $ gem install chef

This plugin is distributed as a Ruby Gem. To install it, run:

    $ gem install knife-hp

Depending on your system's configuration, you may need to run this command with root privileges.

# Configuration #

In order to communicate with HP Helion Compute Cloud's API you will need to tell Knife the Access Key ID, the Secret Key and Tenant ID (found on the "API Keys" page). You may also override the auth URI and availability zone. The easiest way to accomplish this is to create these entries in your `knife.rb` file:

    knife[:hp_access_key] = "Your HP Cloud Access Key ID"
    knife[:hp_secret_key] = "Your HP Cloud Secret Key"
    knife[:hp_tenant_id]  = "Your HP Cloud Tenant ID"
    knife[:hp_auth_uri]   = "Your HP Cloud Auth URI" (optional, default is 'https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/')
    knife[:hp_avl_zone]   = "Your HP Cloud Availability Zone" (optional, default is 'us-west', the other option is 'us-east')
    knife[:hp_ssh_key_id] = "Your HP Cloud Uploaded SSH key" (optional, but strongly suggested)

If your knife.rb file will be checked into a SCM system (ie readable by others) you may want to read the values from environment variables:

    knife[:hp_access_key] = "#{ENV['HP_ACCESS_KEY']}"
    knife[:hp_secret_key] = "#{ENV['HP_SECRET_KEY']}"
    knife[:hp_tenant_id]  = "#{ENV['HP_TENANT_ID']}"
    knife[:hp_auth_uri]   = "#{ENV['HP_AUTH_URI']}"
    knife[:hp_avl_zone]   = "#{ENV['HP_AVL_ZONE']}"

You also have the option of passing your HP Cloud API options from the command line:

    `-A` (or `--hp-access`) your HP Cloud Access Key ID
    `-K` (or `--hp-secret`) your HP Cloud Secret Key
    `-T` (or `--hp-tenant`) your HP Cloud Tenant ID
    `--hp-auth` your HP Cloud Auth URI (optional, default is 'https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/')
    `-Z` (or `--hp-zone`) your HP Cloud Availability Zone (optional, default is 'us-west', the other option is 'us-east')

    knife hp server create -A 'MyUsername' -K 'MyPassword' -T 'MyTenant' -f 101 -I 120 -S hpkeypair -i ~/.ssh/hpkeypair.pem -r 'role[webserver]'

Additionally the following options may be set in your `knife.rb`:

* flavor
* image
* template_file

# Subcommands #

This plugin provides the following Knife subcommands. Specific command options can be found by invoking the subcommand with a `--help` flag

knife hp server create
----------------------

Provisions a new server in the HP Helion Compute Cloud and then perform a Chef bootstrap (using the SSH protocol). The goal of the bootstrap is to get Chef installed on the target system so it can run Chef Client with a Chef Server. The main assumption is a baseline OS installation exists (provided by the provisioning). It is primarily intended for Chef Client systems that talk to a Chef Server. By default the server is bootstrapped using the [chef-full](https://github.com/opscode/chef/blob/master/chef/lib/chef/knife/bootstrap/chef-full.erb) template. This can be overridden using the `-d` or `--template-file` command options. If you do not pass a node name with `-N NAME` (or `--node-name NAME`) a name will be generated for the node.

    knife hp server create -f 101 -I 202e7659-f7c6-444a-8b32-872fe2ed080c -S hpkeypair -i ~/.ssh/hpkeypair.pem

### networking ###

If you do not specify any `--network-ids` and do not specify the `--bootstrap-network`, the server will connect to the default network and boot off of it. If you are not bootstrapping from the HP network, you will need to request a floating IP address to be associated with your node with `--floating-ip` (or `-a`) with or without specifying the IP.

    knife hp server create -a -f 100 -I 202e7659-f7c6-444a-8b32-872fe2ed080c -S hpkeypair -i ~/.ssh/hpkeypair.pem

knife hp server delete
----------------------

Deletes an existing server in the currently configured HP Helion Compute Cloud account. <b>PLEASE NOTE</b> - this does not delete the associated node and client objects from the Chef Server without using the `-P` or `--purge` option to purge the client.

knife hp server list
--------------------

Outputs a list of all servers in the currently configured HP Helion Compute Cloud account by Region. <b>PLEASE NOTE</b> - this shows all instances associated with the account, some of which may not be currently managed by the Chef Server.

knife hp flavor list
--------------------

Outputs a list of all flavors (hardware configuration for a server) available to the currently configured HP Helion Compute Cloud account. Each flavor has a unique combination of virtual CPUs, disk space and memory capacity. This data may be useful when choosing a flavor id to pass to the `knife hp server create` subcommand.

knife hp image list
-------------------

Outputs a list of all images available to the currently configured HP Helion Compute Cloud account. An image is a collection of files used to create or rebuild a server. The returned list filtered and does not contain images with "(deprecated)", "(Kernel)" or "(Ramdisk)" in their names (this may be disabled with `--disable-filter`). This data may be useful when choosing an image id to pass to the `knife hp server create` subcommand.

knife hp group list
--------------------

Outputs a list of the security groups available to the currently configured HP Helion Compute Cloud account by Region. Each group may have multiple rules. This data may be useful when choosing your security group(s) to pass to the `knife hp server create` subcommand.

knife hp network list
---------------------

Lists the networks available to the currently configured HP Helion Compute Cloud account by Region. This data may be useful when choosing your networks to pass to the `knife hp server create` subcommand.

# License #

Author:: Matt Ray (<matt@chef.io>)

Maintainer:: JJ Asghar (<jj@chef.io>)

Copyright:: Copyright (c) 2012-2015 Chef Software, Inc.

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
