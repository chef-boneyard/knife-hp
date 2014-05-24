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
    class HpServerList < Knife

      include Knife::HpBase

      banner "knife hp server list (options)"

      def run
        $stdout.sync = true

        validate!

        server_list = [
          ui.color('Instance ID', :bold),
          ui.color('Name', :bold),
          ui.color('Flavor', :bold),
          ui.color('Image', :bold),
          ui.color('Zone', :bold),
          ui.color('Key Pair', :bold),
          ui.color('State', :bold)
        ]
        connection.list_servers_detail.body['servers'].sort_by { |h| h['name'] }.each do |server|
          Chef::Log.debug("Server: #{server.to_yaml}")

          server_list << server['id']
          server_list << server['name']
          server_list << server['flavor']['id']
          server_list << server['image']['id']
          server_list << server['OS-EXT-AZ:availability_zone']
          server_list << (server['key_name'] or "")
          server_list << begin
                           state = server['status'].downcase
                           case state
                           when 'shutting-down','terminated','stopping','stopped','active(deleting)','build(deleting)','error'
                             ui.color(state, :red)
                           when 'pending','build(scheduling)','build(spawning)','build(networking)'
                             ui.color(state, :yellow)
                           else
                             ui.color(state, :green)
                           end
                         end
        end
        puts ui.list(server_list, :uneven_columns_across, 7)

      end
    end
  end
end
