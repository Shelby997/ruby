require_relative 'helper'

class GemTest < Gem::TestCase
  def test_rubygems_normal_behaviour
    _ = Gem::Util.popen(*ruby_with_rubygems_in_load_path, '-e', "'require \"rubygems\"'", {:err => [:child, :out]}).strip
    assert $?.success?
  end

  def test_operating_system_other_exceptions
    path = util_install_operating_system_rb <<-RUBY
      intentional synt'ax error
    RUBY

    output = Gem::Util.popen(*ruby_with_rubygems_and_fake_operating_system_in_load_path(path), '-e', "'require \"rubygems\"'", {:err => [:child, :out]}).strip
    assert !$?.success?
    assert_includes output, "This is not expected so please report this issue to your OS support and ask for help"
  end

  private

  def util_install_operating_system_rb(content)
    dir_lib = Dir.mktmpdir("test_operating_system_lib", @tempdir)
    dir_lib_arg = File.join dir_lib

    dir_lib_rubygems_defaults_arg = File.join dir_lib_arg, "lib", "rubygems", "defaults"
    FileUtils.mkdir_p dir_lib_rubygems_defaults_arg

    operating_system_rb = File.join dir_lib_rubygems_defaults_arg, "operating_system.rb"

    File.open(operating_system_rb, 'w') {|f| f.write content }

    File.join dir_lib_arg, "lib"
  end

  def ruby_with_rubygems_and_fake_operating_system_in_load_path(operating_system_path)
    [Gem.ruby, "-I", operating_system_path, "-I" , $LOAD_PATH.find{|p| p == File.dirname($LOADED_FEATURES.find{|f| f.end_with?("/rubygems.rb") }) }]
  end
end
