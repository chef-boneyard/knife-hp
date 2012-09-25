#
# Author:: Matt Ray (<matt@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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
          ui.color('Public IP', :bold),
          ui.color('Private IP', :bold),
          ui.color('Flavor', :bold),
          ui.color('Image', :bold),
          ui.color('Key Pair', :bold),
          ui.color('State', :bold)
        ]
        connection.servers.all.sort_by(&:id).each do |server|
          Chef::Log.debug("Server: #{server.to_yaml}")
          server_list << server.id.to_s
          server_list << server.name
          server_list << (server.public_ip_address or "")
          server_list << (server.private_ip_address or "")
          server_list << server.flavor['id'].to_s
          server_list << server.image['id'].to_s
          server_list << (server.key_name or "")
          server_list << begin
                           state = server.state.to_s.downcase
                           case state
                           when 'shutting-down','terminated','stopping','stopped','active(deleting)','build(deleting)'
                             ui.color(state, :red)
                           when 'pending','build(spawning)','build(networking)'
                             ui.color(state, :yellow)
                           else
                             ui.color(state, :green)
                           end
                         end
        end
        puts ui.list(server_list, :uneven_columns_across, 8)

      end
    end
  end
end


