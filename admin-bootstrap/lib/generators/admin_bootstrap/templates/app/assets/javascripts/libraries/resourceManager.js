var ResourceManager = {
    _index: [],
    _show: [],
    _new: [],
    _create: [],
    _edit: [],
    _update: [],
    _destroy: [],

    register: function(resources, callback) {
        var i;
        if(resources == 'all') {
            resources = ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy'];
        }
        if(typeof(resources) == 'string') {
            resources = [resources];
        }
        if(resources instanceof Array) {
            for(i; i < resources.length; i++) {
                this['_' + resources[i]].push(callback);
            }
        }
    },

    launch: function(resource) {
        var i;
        for(i in this['_' + resource]) {
            if(this['_' + resource].hasOwnProperty(i)) {
                this['_' + resource][i]();
            }
        }
    }
};
