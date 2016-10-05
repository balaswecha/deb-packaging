#!/usr/bin/env ruby

key_file = '../key.rb'
require key_file

$current_date = `date -I`
$current_date = $current_date.chomp
def create_package()

   `curl -v -u#{$key} -H "Content-Type: application/json" -X POST https://api.bintray.com/packages/balaswecha/balaswecha-dev --data '{ \"name\": \"balaswecha-videos\", \"licenses\": [ \"GPL-3.0\" ], \"website_url\":\"https://balaswecha.in\", \"vcs_url\":\"https://github.com/balaswecha/deb-packaging\" }'` 
end

def create_version()

   `curl -v -u#{$key} -H "Content-Type: application/json" -X POST https://api.bintray.com/packages/balaswecha/balaswecha-dev/pencilbox/versions --data '{ \"name\": \"1.0-1\", \"release_notes\": \"auto\",\"released\": \"#{$current_date}\" }'`

end

def upload_package()

`curl -v -u#{$key} -H "X-Bintray-Debian-Distribution: trusty,xenial,jessie,stretch" -H "X-Bintray-Debian-Component: main" -H "X-Bintray-Debian-Architecture: all" -H "publish:1" -X PUT -T balaswecha-videos_1.0-1_all.deb https://api.bintray.com/content/balaswecha/balaswecha-dev/balaswecha-videos/1.0-1/pool/main/balaswecha-videos/balaswecha-videos/balaswecha-videos_1.0-1_all.deb`

end

def publish_package()

  `curl -X POST -u#{$key} https://api.bintray.com/content/balaswecha/balaswecha-dev/balaswecha-videos/1.0-1/publish`

end

Dir.chdir('dist') do
  create_package()
  create_version()
  upload_package()
  publish_package()
  puts "Successfully uploaded balaswecha-videos"
end
