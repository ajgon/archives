class AdminBootstrap::Plugins::PaperclipPlugin < AdminBootstrap::Plugins::Base

  default :paperclip do |model|
    model.attachment_definitions.collect do |attachment, options|
      model.admin_column attachment, {:paperclip => attachment, :after => (attachment.to_s + '_updated_at').to_sym}
      options[:styles] = (options[:styles] || {}).merge(:admin_bootstrap => '75x75^')
      model.has_attached_file attachment, options

      attachment = attachment.to_s
      [attachment + '_file_name',
       attachment + '_content_type',
       attachment + '_file_size',
       attachment + '_updated_at']
    end.flatten.each do |attribute|
      model.admin_column attribute.to_sym, :visible => false
    end

  end

  option :paperclip do |value|
    result = []
    result.push formtastic_parameters({:as => :file, :input_html => {'data-url' => "@object.#{value}.url(:admin_bootstrap)"}}) if value
  end

end if defined?(Paperclip)