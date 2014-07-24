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
    class HpRouterList < Knife

      include Knife::HpBase

      require 'chef/knife/hp_base'

      banner "knife hp router list (options)"

      def run

        validate!

        router_list = [
          ui.color('Name', :bold),
          ui.color('ID', :bold),
          ui.color('Tenant', :bold),
          ui.color('Admin State UP', :bold),
          ui.color('Status', :bold),
        ]
        netconnection.list_routers.body['routers'].sort_by { |h| h['name'] }.each do |router|
          router_list << router['name']
          router_list << router['id']
          router_list << router['tenant_id']
          router_list << router['admin_state_up'].to_s
          router_list << router['status']
        end
        puts ui.list(router_list, :uneven_columns_across, 5)
      end
    end
  end
end
