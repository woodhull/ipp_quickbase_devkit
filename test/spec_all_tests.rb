

def ruby19?
  RUBY_VERSION >= "1.9"
end

require 'rubygems'
require 'spec_smoke_tests'
require 'spec_workplace_smoke_tests'
require 'spec_workplace_objects_test'
require 'spec_workplace_addrecord_test'
require 'spec_workplace_editrecord_test'
require 'spec_workplace_json_test'
