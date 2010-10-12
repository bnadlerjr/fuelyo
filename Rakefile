require 'rake'
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
