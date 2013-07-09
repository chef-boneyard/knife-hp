# TODO #
This is a list of features currently lacking and (eventually) under development:
* should we sort the image list like the HP console does? segmented by Public/Partner/Private? "knife hp image list partner"?
* should the node.name and node.id be the same (might have to fix this in the ohai plugin since this appears unavailable for setting)
* take either the flavor ID or the flavor name for server create
* take either the image ID or the image name for server create
* Show the flavor and image names in `hp server list`
* Validate ohai cloud support (waiting on OHAI-425)

## v0.3.1
* KNIFE-309 knife hp server list fails with nil image from boot from volume

## v0.3.0
* update dependency on to Fog 1.10.0
* switched back to hp_access_key from hp_account_id since it's fixed in Fog 1.10.0
* remove support for floating IPs since they're no longer needed, reported by Simon McCartney and Rupak Ganguly
* 'delay-loading' changes to reduce load-time (Mohit Sethi)
* KNIFE-227 added 'knife hp group list' for listing security groups and their rules
* filter out extraneous images from knife hp image list (requires HP metadata not yet available)

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
* Added /etc/chef/ohai/hints/hp.json for use by Ohai

## v0.1.0
* initial developer release
