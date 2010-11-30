require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

TITLE            = 'fuelyo'
MAIN_RDOC        = 'README.rdoc'
TEST_FILES       = Dir['test/**/test_*.rb']
EXTRA_RDOC_FILES = ['README.rdoc', 'HISTORY.txt']

Rake::TestTask.new do |t|
  t.test_files = TEST_FILES
end

Rake::RDocTask.new do |t|
  t.main = MAIN_RDOC
  t.rdoc_dir = 'doc'
  t.rdoc_files.include(EXTRA_RDOC_FILES, 'lib/**/*.rb')
  t.options << '-q'
  t.title = TITLE
end

Rcov::RcovTask.new do |t|
  t.test_files = TEST_FILES
  t.output_dir = 'doc/coverage'
  t.rcov_opts << '-x /Library/Ruby,/.rvm'
end

task :default => ['test']

namespace "assets" do
  desc "Package javascripts"
  task :js do
    system 'jsmin < lib/js/app.js > tmp/app.min.js'
    system 'cat vendor/jquery-1.4.3.min.js vendor/raphael.min.js vendor/leonardo.min.js tmp/app.min.js > public/javascripts/app.js'
  end
end
