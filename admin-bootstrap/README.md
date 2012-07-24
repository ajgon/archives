admin-bootstrap
===============

Quick usage info
----------------

### Initialize

    rake admin_bootstrap:initialize
    
Without parameters it will try guess your templating system. You can use `rake admin_bootstrap:initialize:haml` or `rake admin_bootstrap:initialize:erb` to force proper one.

### Generate scaffold

    script/rails g ModelName
    
A `--haml`/`--no-haml` and `--rspec`/`--no-rspec` options are available

Extensions
----------

*Experimental stuff!* Available in `extensions` branch. Use in model:

    admin_column :description, :wysiwyg => true  # Set WYWSWIG text editor for this field in admin panel         
    admin_column :avatar, :paperclip => true     # Treat set of columns with given prefix as paperclip column
    admin_column :secret, :visible => false      # Hide this row
    admin_column :created_at, :protected => true # Set this field read only