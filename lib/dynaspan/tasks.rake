require 'fileutils'

desc "Create nondigest versions of all dynaspan digest assets"
task "assets:precompile" do
  fingerprint = /\-[0-9a-f]{32}\./
  for file in Dir["public/assets/dynaspan/**/*"]
    next unless file =~ fingerprint
    nondigest = file.sub fingerprint, '.'
    if !File.exist?(nondigest) or File.mtime(file) > File.mtime(nondigest)
      FileUtils.cp file, nondigest, verbose: true
    end
  end
end