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
    class HpNetworkList < Knife

      include Knife::HpBase

      banner "knife hp group list (options)"

      require 'chef/knife/hp_base'

      banner "knife hp network list (options)"

      def run

        validate!

        net_list = [
          ui.color('Name', :bold),
          ui.color('ID', :bold),
          ui.color('Tenant', :bold),
          ui.color('External', :bold),
          ui.color('Shared', :bold),
        ]
        netconnection.list_networks.body['networks'].sort_by { |h| h['name'] }.each do |network|
          net_list << network['name']
          net_list << network['id']
          net_list << network['tenant_id']
          net_list << network['router:external'].to_s
          net_list << network['shared'].to_s
        end
        puts ui.list(net_list, :uneven_columns_across, 5)
      end
    end
  end
end
