include FileUtils::Verbose

namespace :test do

  task :ios do
    run_tests('Unit iOS', 'iphonesimulator')
    puts_failed('iOS failed') unless $?.success?
  end

end

task :install do
  #sh 'sudo easy_install cpp-coveralls'
end

task :test do
  Rake::Task['test:ios'].invoke
end

task :report do
  #sh "./coveralls.sh"
end

private

def run_tests(scheme, sdk)
  puts_green("=== Running '#{scheme}' at '#{sdk}' ===")
  sh("xcodebuild -workspace NinevehGL.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -configuration 'Release' clean test | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
  sh("xctool -workspace NinevehGL.xcworkspace -scheme '#{scheme}' -sdk 'iphonesimulator' -configuration 'Debug' -arch 'i386' clean test ONLY_ACTIVE_ARCH=NO GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES ; exit ${PIPESTATUS[0]}") rescue nil
  puts_green("=== Done '#{scheme}' at '#{sdk}' ===")
end

def puts_failed(string)
  puts "\033[0;31m! #{string} \033[0m"
  exit $?.exitstatus
end

def puts_green(string)
  puts "\033[32;01m #{string} \033[0m"
end
