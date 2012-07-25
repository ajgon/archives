class AdminBootstrap::Plugins::WysiwygPlugin < AdminBootstrap::Plugins::Base

  option :wysiwyg do |value|
    formtastic_parameters :input_html => {:class => 'tinymce'} if value
  end

end