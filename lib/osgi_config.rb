# coding: utf-8

module OsgiConfig
  VERSION = "1.2.0"
  
  module_path = File.expand_path(File.dirname(__FILE__))
  $LOAD_PATH.push(module_path)
  MODULE_PATH = module_path
end


# EOF
