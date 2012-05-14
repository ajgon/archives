var ResourceManager = {
    _index: [],
    _show: [],
    _new: [],
    _create: [],
    _edit: [],
    _update: [],
    _destroy: [],

    register: function(resources, callback) {
        if(resources == 'all') {
            resources = ['index', 'show', 'new', 'create', 'edit', 'update', 'destroy'];
        }
        if(typeof(resources) == 'string') {
            resources = [resources];
        }
        if(resources instanceof Array) {
            for(var resource in resources) {
                this['_' + resources[resource]].push(callback);
            }
        }
    },

    launch: function(resource) {
        for(var i in this['_' + resource]) {
            this['_' + resource][i]();
        }
    }
};
