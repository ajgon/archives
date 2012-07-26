class AdminBootstrap::Plugins::CorePlugin < AdminBootstrap::Plugins::Base

  option :visible do |value|
    set_visibility value
  end

  option :protected do |value|
    formtastic_parameters :input_html => {:readonly => 'readonly', :disabled => 'disabled'} if value
  end

  option :hidden do |value|
    formtastic_parameters :input_html => {:type => :hidden}, :wrapper_html => {:style => 'display: none;'}
  end

  # Hide all binary columns
  default :serve_the_public_trust do |model|
    model.columns.find_all do |column|
      column.type == :binary
    end.collect(&:name).each do |attribute|
      model.admin_column attribute.to_sym, :visible => false
    end
  end

  # Set all protected columns to read-only
  default :protect_the_innocent do |model|
    (model.column_names - model.accessible_attributes.to_a).each do |attribute|
      model.admin_column attribute.to_sym, :protected => true
    end
  end

  # Hide all referential (*_id) columns
  default :uphold_the_law do |model|
    model.reflect_on_all_associations.collect(&:association_foreign_key).uniq.each do |attribute|
      model.admin_column attribute.to_sym, :hidden => true
    end
  end

  # Admin options

  # Hide protected rows
  default :hide_protected_rows do |model|
    if model.admin_option_value(:hide_protected_rows)
      model.admin_columns.collect {|k, v| k if v[:protected] }.compact.each do |attribute|
        model.admin_column attribute.to_sym, :visible => false
      end
    end
  end

end
