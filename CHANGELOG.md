# TODO #
This is a list of features currently lacking and (eventually) under development:
* filter out extraneous images from knife hp image list (requires HP metadata not yet available)
* should the node.name and node.id be the same (might have to fix this in the ohai plugin)
* take either the flavor ID or the flavor name for server create
* take either the image ID or the image name for server create
* Virtual cpus to `hp flavor list`?
* Show the flavor and image names in `hp server list`
* Add support for `--private-network` for bootstrapping private networks
* Floating IPs are assigned on creation, but the public ip is incorrect
* Floating IPs are assigned on creation, support creating nodes without them
* Floating IPs are freed on node deletion, support not freeing them
* Re-assign a floating IPs on node creation

## v0.2.0
* support for uneven_columns for prettier output
* added bootstrap-proxy support. (Matt Butcher)
* updated to point to Fog 1.4.0 for `HP` provider
* chef-full is now default bootstrap template
* Add support for floating IPs and address associating
* push the AZ stuff into the hints file
* Add support for `--no-host-key-verify`
* switched from hp_account_id to hp_access_key (Hugues Malphettes reported)
  patch didn't make it into Fog 1.4, so reverted for now
* --purge (and --node-name) added for `knife hp server delete` to remove client and nodes
* Floating IPs are automatically disassociated on server delete

* Add /etc/chef/ohai/hints/hp.json, the `openstack` Ohai plugin keys off of it and pulls from the meta-data service.

## v0.1.0
* initial developer release
