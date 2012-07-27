var ResourceManager = {
    resources: [],

    register: function(resources, callback) {
        var i;
        if(typeof(resources) == 'function') {
            callback = resources;
            resources = {};
        }
        if(typeof(resources) == 'string') {
            resources = {only: [resources]};
        }
        if(resources instanceof Array) {
            resources = {only: resources};
        }
        if(resources.only && typeof(resources.only) == 'string') {
            resources.only = [resources.only];
        }
        if(resources.except && typeof(resources.except) == 'string') {
            resources.except = [resources.except];
        }
        resources.callback = callback;
        this.resources.push(resources);
    },

    launch: function(resource) {
        var i, res_len = this.resources.length;

        for(i = 0; i < res_len; i++) {
            if(this.resources[i].only) {
                if($.inArray(resource, this.resources[i].only) > -1) {
                    this.resources[i].callback();
                }
            } else if(this.resources[i].except) {
                if($.inArray(resource, this.resources[i].except) == -1) {
                    this.resources[i].callback();
                }
            } else {
                this.resources[i].callback();
            }
        }
    }
};
