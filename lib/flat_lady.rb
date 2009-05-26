require 'state_machine'
# require 'evil_twin'
require 'flat_lady/imported_ressource'
require 'flat_lady/jobs'
require 'import_file.rb'

class ActionController::Routing::RouteSet
  def load_routes_with_flat_lady!
    lib_path = File.dirname(__FILE__)
    flat_lady_routes = File.join(lib_path, *%w[.. config flat_lady_routes.rb])
    unless configuration_files.include?(flat_lady_routes)
      add_configuration_file(flat_lady_routes)
    end
    load_routes_without_flat_lady!
  end

  alias_method_chain :load_routes!, :flat_lady
end

 