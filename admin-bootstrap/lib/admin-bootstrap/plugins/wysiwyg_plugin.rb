class AdminBootstrap::Plugins::WysiwygPlugin < AdminBootstrap::Plugins::Base

  option :wysiwyg do |value|
    result = []
    result.push formtastic_parameters(:input_html => {:class => 'tinymce'}) if value
  end

end