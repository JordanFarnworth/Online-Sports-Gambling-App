require 'yaml'

RolesHelper.permissions ||= {}
y = YAML.load_file(File.dirname(__FILE__) + '/../permissions.yml')
RolesHelper.permissions = y