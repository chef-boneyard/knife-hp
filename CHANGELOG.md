## v0.4.2rc1
* Updated the README.md to reflect the new names of the regions
* Fixed the defaulting to the US-West region

## v0.4.0
* Upgrade to support 13.5 HP Helion Public Cloud Services. For more information check https://docs.hpcloud.com/migration-overview/
* KNIFE-444 knife-hp incompatible with hpcloud v13.5
* Added support for HP's regions (US East and US West) and the availability zones within those regions
* Added 'knife hp network list'
* Added floating IP address support
* Added --networks to specify networks to attach to
* Replaced --private-network with --bootstrap-network

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
