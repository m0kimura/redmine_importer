require 'redmine'

Redmine::Plugin.register :redmine_importer do
  name 'Redmine CSV Importer Plugin'
  author 'Piroli UENISHI (SKYARC System)'
  description 'Import tasks from CSV'
  version '0.0.3'

  menu :application_menu, :importer, { :controller => 'importer', :action => 'index' }, :caption => 'CSV Import'
end
