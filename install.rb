#!/usr/bin/env ruby
require 'pathname'

# where the configs are kept
APP_DIR="./config"
IGNORE=[".", "..", ".git", ".svn"]

# ------------------------------------------------------------------------

# List all available apps
def list(configs)
  puts "Available Configs:"
  configs.each{|app, dir|
    files, dirs = 0, 0
    Dir.foreach(dir){|f|
      if not IGNORE.include?(f) then
        if File.directory?(f) then
          dirs += 1
        else
          files += 1
        end
      end
    }
    puts "    #{app} \t: #{files} file#{(files==1)?'':'s'}, #{dirs} dir#{(dirs == 1)?'':'s'}."
  }
end

# List files for an app
def list_files(configs, a)
  puts "Files for #{a}:"

  count   = 0
  sum_fs  = 0
  Dir.foreach(configs[a]).each{|f|
    if not IGNORE.include?(f) then
      full_path = File.join(configs[a], f)
      puts " #{count+=1}. #{f}#{File.directory?(full_path)? '/':''}"
      sum_fs += File.size(full_path)
    end
  }
  
  puts "#{count} file#{(count==1)?'':'s'}, sum #{sum_fs}B."
end

# Copy files to ~ as symlinks.
def install(configs, a, target)
  print "Installing #{a} to #{target}..."

  symlinks = {}
  collisions = []
  configs[a].entries.each{|f|
    if not IGNORE.include?(f.to_s)
      # Compute symlink targets
      to = File.join(target, f)
      f  = Pathname.new(File.join(APP_DIR, a, f)).expand_path

      # debug
      # puts " #{to} => #{f}"
      
      # account
      symlinks[to] = f
      if File.symlink?(to) then
        if not (File.readlink(to) == f.to_s) then
          collisions << to 
        end
      elsif File.exists?(to)
        collisions << to 
      end
    end
  }

  # test to see what exists
  if collisions.length > 0 then
    $stderr.puts "\n\nError preparing for #{a}: #{collisions.length} file[s] already exist or are symlinks to somewhere else."
    $stderr.puts "To rectify, copy-paste:"
    collisions.map{|x| puts "rm -#{(File.directory?(x))?'r':''}f \"#{x}\"" }
    exit(1)
  end

  # Then do it
  symlinks.each{|new, old|
    # Only bother writing if the symlink is different
    if File.symlink?(new) and File.readlink(new) == old.to_s then
      # puts "Skipping #{new}"
    else
      File.symlink(old, new)
    end
  }

  print "Done.\n"
end

# rm symlinks
def uninstall(configs, a, target)
  print "Uninstalling #{a} from #{target}..."

  symlinks    = []
  not_symlinks = []
  wrong_target = []
  configs[a].entries.each{|f|
    if not IGNORE.include?(f.to_s)
      # Compute symlink targets
      to = File.join(target, f)
      f  = Pathname.new(File.join(APP_DIR, a, f)).expand_path

      # debug
      # puts " Removing #{to} if it links to #{f}"

      # Account
      if File.symlink?(to) then
        if File.readlink(to) == f.to_s then
          symlinks << to    # Add to the list to delete 
        else
          wrong_target << to    # symlink points at wrong place
        end
      elsif File.exists?(to)
        not_symlinks << to  # File is not a symlink
      end
    end
  }

  # test to see what exists
  errors = (wrong_target.length > 0 or not_symlinks.length > 0)
  if wrong_target.length > 0 then
    $stderr.puts "\n\nERROR #{wrong_target.length} link[s] point at the wrong targets."
    $stderr.puts "To rectify, inspect and then delete/move them:"
    wrong_target.map{|x| puts "rm -#{(File.directory?(x))?'r':''}f \"#{x}\"" }
  end

  # test to see what exists
  if not_symlinks.length > 0 then
    $stderr.puts "\n\nERROR #{not_symlinks.length} file[s] are not symlinks."
    $stderr.puts "To rectify, inspect and then delete/move them:"
    not_symlinks.map{|x| puts "rm -#{(File.directory?(x))?'r':''}f \"#{x}\"" }
  end

  # And quit if we errored
  exit(1) if errors


  # Then do it
  symlinks.each{|l|
    File.delete(l)
  }

  print "Done.\n"
end

# ------------------------------------------------------------------------
# Symlinks things from the repo into their "proper" location for deployment.
#
if ARGV.length < 1 then
  $stderr.puts "USAGE: #{__FILE__} [list|install|uninstall] [app] [app2] [app3] [HOME]"
  $stderr.puts ""
  $stderr.puts "HOME is only required if the action is install or uninstall"
  exit(1)
end

# Load the action
action = ARGV[0].downcase
if not %w{install uninstall list}.include?(action) then
  $stderr.puts "#{action} is not a recognised action!"
  exit(1)
end

# Check we can read the list.
if not File.directory?(APP_DIR) or not File.readable?(APP_DIR) then
  $stderr.puts "Cannot access #{APP_DIR}, or it's not a directory."
  exit(1)
end

# Load a list of files
configs = {}
Dir.foreach(APP_DIR){|f|
  if not IGNORE.include?(f) then
    f = Pathname.new(File.join(APP_DIR, f))
    f = f.expand_path if not f.absolute?
    configs[File.basename(f)] = f if f.directory?  # Load if it's a dir
  end
}

# Read the target as last arg
target = nil
apps = ARGV[1..-1]
if %w{install uninstall}.include?(action) then

  # Check there's enough arguments and load the target
  if apps.length > 0 then
    target = apps[-1]
    apps = apps[0..-2]
  else
    $stderr.puts "Insufficient arguments.  Install/uninstall require a target."
    exit(1)
  end

  # Load target as absolute path for symlinking
  target = Pathname.new(target)
  target = target.expand_path if not target.absolute?
end

# Load the other arguments and ensure they're in configs
apps.each{|a|
  if not configs.keys.include?(a)
    $stderr.puts "No config for app: #{a}"
    exit(1)
  end
}



# convert to symbol for easier editing
action = action.to_sym

# ------------------------------------------------------------------------
# Do things
#
case action
  when :list
    # List some apps, or the files in them
    if apps.length == 0 then
      list(configs)
    else
      apps.each{|a|
        list_files(configs, a)
      }
    end

  when :install
    # All the apps people want
    if apps.length == 0 then
      puts "Installing all #{configs.length} configs..."
      apps = configs.keys
    end

    # Install them
    apps.each{|a|
      install(configs, a, target)
    }
  when :uninstall
    puts "Installing to #{target}"

    # All the apps people want
    if apps.length == 0 then
      puts "Uninstalling all #{configs.length} configs..."
      apps = configs.keys
    end

    # Uninstall them
    apps.each{|a|
      uninstall(configs, a, target)
    }
end
puts "Done."
