class AdminBootstrap::Plugins::Base
  extend AdminBootstrap::Plugins::Callbacks

  @@options = {}
  @@inputs = {}
  @@defaults = {}

  @@enabled = true

  def self.options
    @@options
  end

  def self.defaults
    @@enabled ? @@defaults : {}
  end

  def self.default name, &block
    @@defaults[name.to_sym] = block
  end

  def self.remove_default name
    @@defaults.delete(name.to_sym)
  end

  def self.option name, &block
    @@options[name.to_sym] = block
  end

  def self.call param, value, *args
    if @@enabled and @@options[param.to_sym]
      @@options[param.to_sym].call(value, *args)
    else
      {}
    end
  end

  def self.disable!
    @@enabled = false
  end

  def self.enable!
    @@enabled = true
  end

  def self.disabled?
    !@@enabled
  end

  def self.enabled?
    @@enabled
  end

end