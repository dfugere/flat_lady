module FlatLady::ImportFilesHelper
  def alt_tr(options={})
    haml_tag :tr, {:class => cycle('odd', 'even')}.merge(options) do
      yield
    end
  end
  
end