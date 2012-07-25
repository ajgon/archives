class AdminBootstrap::Plugins::PaperclipPlugin < AdminBootstrap::Plugins::Base

  default :paperclip do |model|
    model.attachment_definitions.keys.each do |column|
      model.admin_column column, :paperclip => true
    end if model.attachment_definitions
  end

  option :paperclip do |value, model, column|
    if value
      attachment = model.attachment_definitions[column]
      if attachment
        model.admin_column column, :after => ((column = column.to_s) + '_updated_at').to_sym
        attachment[:styles] = (attachment[:styles] || {}).merge(:admin_bootstrap => '75x75^')
        model.has_attached_file column, attachment
        [column + '_file_name',
         column + '_content_type',
         column + '_file_size',
         column + '_updated_at'].each do |attr|
          model.admin_column attr.to_sym, :visible => false
        end
      end
      formtastic_parameters :as => :file, :input_html => {'data-url' => "@object.#{column}.url(:admin_bootstrap)"}
    end
  end

end if defined?(Paperclip)