#
# Author:: Matt Ray (<matt@getchef.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
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

class Chef
  class Knife
    class HpSubnetList < Knife

      include Knife::HpBase

      require 'chef/knife/hp_base'

      banner "knife hp subnet list (options)"

      def run

        validate!

        subnet_list = [
          ui.color('Name', :bold),
          ui.color('ID', :bold),
          ui.color('Tenant', :bold),
          ui.color('Network ID', :bold),
          ui.color('Gateway IP', :bold),
          ui.color('CIDR Addr', :bold),
        ]
        netconnection.list_subnets.body['subnets'].sort_by { |h| h['name'] }.each do |subnet|
          subnet_list << subnet['name']
          subnet_list << subnet['id']
          subnet_list << subnet['tenant_id']
          subnet_list << subnet['network_id']
          subnet_list << subnet['gateway_ip']
          subnet_list << subnet['cidr']
        end
        puts ui.list(subnet_list, :uneven_columns_across, 6)
      end
    end
  end
end
