require "fileutils"
require "pathname"

require_relative "./workspace"
require_relative "./database"

command = ARGV.shift

case command
when "init"
  path = ARGV.fetch(0, Dir.getwd)

  root_path = Pathname.new(File.expand_path(path))
  git_path = root_path.join(".lit")

  ["objects", "refs"].each do |dir|
    begin
      FileUtils.mkdir_p(git_path.join(dir))
    rescue Errno::EACCES => error
      $stderr.puts "fatal: #{ error.message }"
      exit 1
    end
  end

  puts "Initialized empty lit repository in #{git_path}"
  exit 0
when "commit"
  root_path = Pathname.new(Dir.getwd)
  git_path  = root_path.join(".lit")
  db_path   = git_path.join("objects")

  workspace = Workspace.new(root_path)
  database  = Database.new(db_path)

  workspace.list_files.each do |path|
    data = workspace.read_file(path)
    blob = Blob.new(data)

    database.store(blob)
  end
else
  $stderr.puts "lit: '#{command}' is not a lit command."
  exit 1
end
