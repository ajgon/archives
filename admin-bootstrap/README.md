admin-bootstrap
===============

![deprecated](http://ajgon.github.io/images/deprecated.png)

Quick usage info
----------------

### Initialize

    rake admin_bootstrap:initialize
    
Without parameters it will try guess your templating system. You can use `rake admin_bootstrap:initialize:haml` or `rake admin_bootstrap:initialize:erb` to force proper one.

### Generate scaffold

    script/rails g admin_bootstrap ModelName
    
A `--haml`/`--no-haml` and `--rspec`/`--no-rspec` options are available

Extensions
----------

*Experimental stuff!* In your model:

    admin do

        column <column> :visible => true|false,                              # column IS NOT visible and IS NOT posted
                        :protected => true|false,                            # column   IS   visible and IS NOT posted
                        :hidden => true|false,                               # column IS NOT visible but   IS   posted
                        :image => true|false,                                # in index and show view, content gets
                                                                             # class="image" and it's wrapped in
                                                                             # <img src="" /> tag
                        :class => 'class_name',                              # in index and show view, content wrapper
                                                                             # gets specified class
                        :value => lambda {|column_value| ... },              # in index and show view, column value is
                                                                             # processed by block
                        :country => true|{:codes => true|false},             # in edit and add display field as a list
                                                                             # of countries (with codes = true - option
                                                                             # values are country codes)
                        :state => {:country => US|CA, :codes => true|false}, # same as for country, but show states
                        :wysiwyg => true|false,                              # display field as a rich text editor
                                                                             # (using TinyMCE)
                        :password => true|false,                             # display field as password field
                        :paperclip => true|false,                            # only if Paperclip Gem is used - treat
                                                                             # column as paperclip column (remember to
                                                                             # use "virtual" paperclip column name)
                        :before => :column_name,                             # display this column before specified
                                                                             # column (used for virtual columns)
                        :after => :column_name,                              # like :before, but after ;)
                        :replace => :column_name                             # pretty self-explainatory

        hide_protected_rows                        # If provided all protected columns will also be invisible
                                                   # (:visible => false)
        disabled_actions [:new, :create, :etc]     # REST actions disabled for this model
        additional_actions [:approve, :etc]        # Additional actions for this model
        columns_order [:column_3, :column_5, :etc] # Table with column names in correct order, all visble columns not
                                                   # included there will be show at the end

    end
