require 'test_helper'
require 'fileutils'
require 'compass'
require 'compass/exec'
require 'timeout'

class CommandLineTest < Test::Unit::TestCase
  include Compass::TestCaseHelper
  include Compass::CommandLineHelper
  include Compass::IoHelper

  def teardown
    Compass.reset_configuration!
  end

  def test_print_version
    compass("-vq")
    assert_match(/\d+\.\d+\.(\d+|((alpha|beta|rc)\.\d+\.[0-9a-f]+))?/, @last_result)
  end

  def test_basic_install
    within_tmp_directory do
      compass(*%w(create --boring basic))
      assert File.exist?("basic/sass/screen.scss")
      assert_action_performed :directory, "basic/"
      assert_action_performed    :create, "basic/sass/screen.scss"
    end
  end

  Compass::Frameworks::ALL.each do |framework|
    next if framework.name == "true"
    next if framework.name == "testing"
    next if framework.name =~ /^_/
    define_method "test_#{framework.name}_installation" do
      within_tmp_directory do
        compass(*%W(create --boring --using #{framework.name} #{framework.name}_project))
        assert File.exist?("#{framework.name}_project/sass/screen.scss"), "sass/screen.scss is missing. Found: #{Dir.glob("#{framework.name}_project/**/*").join(", ")}"
        assert File.exist?("#{framework.name}_project/stylesheets/screen.css")
        assert_action_performed :directory, "#{framework.name}_project/"
        assert_action_performed    :create, "#{framework.name}_project/sass/screen.scss"
        assert_action_performed    :write, "#{framework.name}_project/stylesheets/screen.css"
      end
    end
  end

  def test_basic_update
    within_tmp_directory do
      compass "create", "--boring", "basic"
      Dir.chdir "basic" do
        # basic update with timestamp caching
        compass "compile", "--boring"
        # assert_action_performed :unchanged, "sass/screen.scss"
        # basic update with force option set
        compass "compile", "--force", "--boring"
        assert_action_performed :write, "stylesheets/screen.css"
      end
    end
  end

end
