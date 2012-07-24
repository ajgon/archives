class AdminBootstrap::Plugins::CorePlugin < AdminBootstrap::Plugins::Base

  option :visible do |value|
    [ visibility_toggle(value) ]
  end

  option :protected do |value|
    result = []
    result.push formtastic_parameters(:input_html => {:readonly => 'readonly', :disabled => 'disabled'}) if value
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

  # Yeah, yeah, I know ;-)
  default :uphold_the_law do |model|

  end

end