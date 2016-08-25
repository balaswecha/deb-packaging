#!/usr/bin/env ruby

apps_data_file = './apps.rb'
require apps_data_file
key_file = '../key.rb'
require key_file

$current_date = `date -I`
$current_date = $current_date.chomp
def create_package(app)

   `curl -v -u#{$key} -H "Content-Type: application/json" -X POST https://api.bintray.com/packages/balaswecha/balaswecha-dev --data '{ \"name\": \"#{app["name"]}\", \"licenses\": [ \"GPL-3.0\" ], \"website_url\":\"https://phet.colorado.edu/en/simulation/#{app["name"]}\", \"vcs_url\":\"https://phet.unfuddle.com/a#/repositories/23262/browse?path=/trunk\" }'` 
end

def create_version(app)

   `curl -v -u#{$key} -H "Content-Type: application/json" -X POST https://api.bintray.com/packages/balaswecha/balaswecha-dev/#{app["name"]}/versions --data '{ \"name\": \"1.0-1\", \"release_notes\": \"auto\",\"released\": \"#{$current_date}\" }'`

end

def upload_package(app)

`curl -v -u#{$key} -H "X-Bintray-Debian-Distribution: trusty" -H "X-Bintray-Debian-Component: main" -H "X-Bintray-Debian-Architecture: amd64" -H "publish:1" -X PUT -T #{app["name"]}_1.0-1_amd64.deb https://api.bintray.com/content/balaswecha/balaswecha-dev/#{app["name"]}/1.0-1/pool/main/#{app["name"].chars.first}/#{app["name"]}/#{app["name"]}_1.0-1_amd64.deb`

end

def publish_package(app)

  `curl -X POST -u#{$key} https://api.bintray.com/content/balaswecha/balaswecha-dev/#{app["name"]}/1.0-1/publish`

end

Dir.chdir('dist') do
  $apps.each do |app|
    Dir.chdir(app["name"]) do
      create_package(app)
      create_version(app)
      upload_package(app)
      publish_package(app)
    end
    puts "++++++++++++++++++++\nUploaded #{app["name"]}..\n+++++++++++++++++++++\n"
  end
  puts "Successfully uploaded All packages"
end
