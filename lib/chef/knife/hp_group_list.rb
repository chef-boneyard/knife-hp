#
# Author:: Matt Ray (<matt@getchef.com>)
# Copyright:: Copyright (c) 2013-2014 Chef Software, Inc.
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
    class HpGroupList < Knife

      include Knife::HpBase

      banner "knife hp group list (options)"

      def run

        validate!

        group_list = [
          ui.color('Name', :bold),
          ui.color('Direction', :bold),
          ui.color('Type', :bold),
          ui.color('Protocol', :bold),
          ui.color('Port Range', :bold),
          ui.color('Remote', :bold),
          ui.color('Description', :bold),
        ]
        netconnection.security_groups.sort_by(&:name).each do |group|
          group.security_group_rules.each do |rule|
            unless rule['protocol'].nil?
              group_list << group.name
              group_list << rule['direction']
              group_list << rule['ethertype']
              group_list << rule['protocol']
              group_list << "#{rule['port_range_min']}-#{rule['port_range_max']}"
              group_list << rule['remote_ip_prefix']
              group_list << group.description
            end
          end
        end
        puts ui.list(group_list, :uneven_columns_across, 7)
      end
    end
  end
end
