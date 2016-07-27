#!/usr/bin/env ruby

require 'fileutils'
apps_data_file= './apps.rb'


require apps_data_file
puts $apps

BASE_URL='http://phet.colorado.edu/sims/html/'

def uri_for(app)
  "#{BASE_URL}#{app}/latest/#{app}_en.html"
  #"http://localhost/#{app}_en.html"
end

def icon_for(app)
  "#{BASE_URL}#{app}/latest/#{app}-600.png"
end

def download_app(app)
  `wget -nv #{uri_for(app)}`
end

def download_icon(app)
  `wget -nv #{icon_for(app)}`
end

def generate_tar(app, version)
  appWithVersion = "#{app}-#{version}"
  Dir.mkdir(appWithVersion)
  Dir.chdir(appWithVersion) do
    download_app(app)
    download_icon(app)
    generate_desktop(app)
    generate_bin(app)
  end
  tar_filename = "#{app}_#{version}.orig.tar.gz"
  `tar czf #{tar_filename} #{appWithVersion}`
  FileUtils.rm_rf(appWithVersion)
  tar_filename
end

def extract_tar(filename)
  `tar xzf #{filename}`
end

def generate_deb_files(app, version)
  puts "Generating Deb files ..."
  Dir.mkdir('debian')
  Dir.chdir('debian') do
    generate_changelog(app)
    generate_control(app)
    generate_compat(app)
    generate_copyright(app)
    generate_rules(app)
    generate_install(app)
    generate_format(app)
  end
  puts ".. Done!"
end

def generate_copyright(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    GPL V3
  FILE
  File.write('copyright', contents)
end

def generate_rules(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    #!/usr/bin/make -f
    %:
    	dh $@
    override_dh_usrlocal:
  FILE
  File.write("rules", contents)
end

def generate_format(app)
  Dir.mkdir('source')
  Dir.chdir('source') do
    contents = <<-FILE.gsub(/^ {6}/, '')
      3.0 (quilt)
    FILE
    File.write('format', contents)
  end
end

def generate_install(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    #{app}_en.html usr/local/lib/balaswecha/html
    #{app}.desktop usr/share/applications
    #{app}-600.png /usr/share/icons
  FILE
  File.write("#{app}.install", contents)
end

def generate_control(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    Source: #{app}
    Maintainer: Balaswecha Team<balaswecha-dev-team@thoughtworks.com>
    Section: misc
    Priority: optional
    Standards-Version: 3.9.2
    Build-Depends: debhelper (>= 9)

    Package: #{app}
    Architecture: any
    Depends: ${shlibs:Depends}, ${misc:Depends},firefox
    Description: #{app}
     #{app} is an educational simulation.
  FILE
  File.write('control', contents)
end

def generate_desktop(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    [Desktop Entry]
    Name=#{app}
    Comment=Simulation for #{app}
    Exec=#{app}
    Icon=#{app}-600
    Terminal=false
    Type=Application
    Categories=Simulations
  FILE

  File.write("#{app}.desktop",contents)
end

def generate_bin(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    firefox --new-window /usr/local/lib/balaswecha/html/#{app}_en.html
  FILE
  File.write(app, contents)
end

def generate_changelog(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
    #{app} (1.0-1) UNRELEASED; urgency=low

      * Initial release. (Closes: #XXXXX)

     -- Balaswecha Team <balaswecha-dev-team@thoughtworks.com>  #{Time.now.strftime '%a, %-d %b %Y %H:%M:%S %z'}
  FILE
  File.write('changelog', contents)
end

def generate_compat(app)
  File.write('compat', "9\n")
end

def generate_deb
  `debuild -us -uc`
end

FileUtils.rm_rf 'dist'
Dir.mkdir('dist')
Dir.chdir('dist') do
  #apps = apps.take(1)
  $apps.each do |app|
    Dir.mkdir(app)
    Dir.chdir(app) do
      version = "1.0"
      tar_filename = generate_tar(app, version)
      extract_tar(tar_filename)
      Dir.chdir("#{app}-#{version}") do
        generate_deb_files(app, version)
        generate_deb
      end
    end
  end
end
