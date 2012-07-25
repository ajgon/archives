class AdminBootstrap::Plugins::PasswordPlugin < AdminBootstrap::Plugins::Base

  option :password do |value, model, column|
    encrypted_column = ('encrypted_' + column.to_s)
    model.admin_column encrypted_column.to_sym, :visible => false if model.column_names.include?(encrypted_column)
    formtastic_parameters(:input_html => {:type => 'password'}) if value
  end


end
