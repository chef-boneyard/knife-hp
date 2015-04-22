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
    class HpVolumeList < Knife

      include Knife::HpBase

      require 'chef/knife/hp_base'

      banner "knife hp volume list (options)"

      def run

        validate!

        volume_list = [
          ui.color('Name', :bold),
          ui.color('ID', :bold),
          ui.color('Size', :bold),
          ui.color('Availability_Zone', :bold),
          ui.color('Status', :bold),
        ]
        volconnection.list_volumes.body['volumes'].sort_by { |h| h['name'] }.each do |volume|
          volume_list << volume['display_name']
          volume_list << volume['id']
          volume_list << volume['size'].to_s
          volume_list << volume['availability_zone']
          volume_list << volume['status']
        end
        puts ui.list(volume_list, :uneven_columns_across, 5)
      end
    end
  end
end
