#!/usr/bin/env ruby

require 'fileutils'

native_apps = ["celestia",
               "geogebra",
               "kgeography",
               "kalzium",
               "kbruch",
               "stellarium",
               "step",
               "tuxmath",
               "openteacher",
               "khangman",
               "turtleart",
               "marble",
               "kwordquiz",
               "kturtle",
               "gcompris",
               "klettres"]

def get_apps(type)
  require "../phetsims/#{type}/apps.rb"
  return $apps
end

java_apps = get_apps('java').map { |app| app["name"] }

flash_apps = get_apps('flash') 

html_apps = get_apps('html')

dependency_str = (java_apps + flash_apps + html_apps + native_apps).join(', ')
puts dependency_str

app = 'balaswecha-apps'

def generate_meta_files(app, version,dependency_str)
  puts "Generating Deb files ..."
  Dir.mkdir('debian')
  Dir.chdir('debian') do
    generate_changelog(app)
    generate_control(app,dependency_str)
    generate_compat()
    generate_copyright()
    generate_rules()
    generate_format()
  end
end

def generate_copyright()
  contents = <<-FILE.gsub(/^ {4}/, '')
    GPL V3
  FILE
  File.write('copyright', contents)
end

def generate_rules()
  contents = <<-FILE.gsub(/^ {4}/, '')
    #!/usr/bin/make -f
    %:
    	dh $@
    override_dh_usrlocal:
  FILE
  File.write("rules", contents)
end

def generate_format()
  Dir.mkdir('source')
  Dir.chdir('source') do
    contents = <<-FILE.gsub(/^ {6}/, '')
      3.0 (quilt)
    FILE
    File.write('format', contents)
  end
end

def generate_control(app,dependency_str)
  contents = <<-FILE.gsub(/^ {4}/, '')
    Source: #{app}
    Maintainer: Balaswecha Team<balaswecha-dev-team@thoughtworks.com>
    Section: misc
    Priority: optional
    Standards-Version: 3.9.2
    Build-Depends: debhelper (>= 9)

    Package: #{app}
    Architecture: all
    Depends: ${shlibs:Depends}, ${misc:Depends}, #{dependency_str}
    Description: Meta-package for all Balaswecha Applications
  FILE
  File.write('control', contents)
end

def generate_changelog(app)
  contents = <<-FILE.gsub(/^ {4}/, '')
#{app} (1.0-1) UNRELEASED; urgency=low

      * Initial release. (Closes: #XXXXX)

     -- Balaswecha Team <balaswecha-dev-team@thoughtworks.com>  #{Time.now.strftime '%a, %-d %b %Y %H:%M:%S %z'}
  FILE
  File.write('changelog', contents)
end

def generate_compat()
  File.write('compat', "9\n")
end

def generate_deb
  `debuild -i -us -uc -b`
  puts "Done!"
end

FileUtils.rm_rf 'dist'
Dir.mkdir('dist')
Dir.chdir('dist') do
  version = "1.0"
  Dir.mkdir("#{app}-#{version}")
  Dir.chdir("#{app}-#{version}") do
    generate_meta_files(app, version,dependency_str)
    generate_deb
  end
end
