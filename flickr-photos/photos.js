/*global jQuery*/

var setupPhotos = (function ($) {
    function each (items, callback) {
        var i;
        for (i = 0; i < items.length; i += 1) {
            setTimeout(callback.bind(this, items[i]), 0);
        }
    }

    function flatten (items) {
        return items.reduce(function (a, b) {
            return a.concat(b);
        });
    }

    function loadPhotosByTag (tag, max, callback) {
        var photos = [];
        var callback_name = 'callback_' + Math.floor(Math.random() * 100000);

        window[callback_name] = function (data) {
            delete window[callback_name];
            var i;
            for (i = 0; i < max; i += 1) {
                photos.push(data.items[i].media.m);
            }
            callback(null, photos);
        };

        $.ajax({
            url: 'http://api.flickr.com/services/feeds/photos_public.gne',
            data: {
                tags: tag,
                lang: 'en-us',
                format: 'json',
                jsoncallback: callback_name
            },
            dataType: 'jsonp'
        });
    }

    function loadAllPhotos (tags, max, callback) {
        var results = [];
        function handleResult (err, photos) {
            if (err) { return callback(err); }

            results.push(photos);
            if (results.length === tags.length) {
                callback(null, flatten(results));
            }
        }

        each(tags, function (tag) {
            loadPhotosByTag(tag, max, handleResult);
        });
    }

    function renderPhoto (photo) {
        var img = new Image();
        img.src = photo;
        return img;
    }

    function imageAppender (id) {
        var holder = document.getElementById(id);
        return function (img) {
            var elm = document.createElement('div');
            elm.className = 'photo';
            elm.flickr_id = img.src.match(/\/([0-9]+)_/)[1];
            elm.appendChild(img);
            holder.appendChild(elm);
            addFavourite(elm);
        };
    }

    function addFavourite( for_elm ) {
        var fav_btn = document.createElement('a');
        fav_btn.className = 'favourite ' + (FavIds.get().indexOf(for_elm.flickr_id.toString()) >= 0 ? 'icon-heart' : 'icon-heart-empty');
        fav_btn.href = '#';
        fav_btn.toggleFavourite = toggleFavourite.bind(fav_btn);
        fav_btn.addEventListener('click', function(e) {
            var item = e.target;
            e.preventDefault();
            item.toggleFavourite(item.className.match('icon-heart-empty'));
        });
        for_elm.appendChild(fav_btn);
    }

    function toggleFavourite() {
        if(this.className.match('icon-heart-empty')) {
            this.className = this.className.replace('icon-heart-empty', 'icon-heart');
            FavIds.add(this.parentNode.flickr_id);
        } else {
            this.className = this.className.replace('icon-heart', 'icon-heart-empty');
            FavIds.remove(this.parentNode.flickr_id);
        }
    }

    var FavIds = {
        get: function() {
            var fav_ids = (document.cookie.match(/fav_ids=([0-9,]*)/) || ['', ''])[1].split(','),
                empty_index = fav_ids.indexOf('');
            if(empty_index >= 0) { fav_ids.splice(empty_index, 1); }
            return fav_ids;
        },
        add: function(fav_id) {
            FavIds.remove(fav_id);
            document.cookie = 'fav_ids=' + FavIds.get().concat([fav_id]).join(',');
        },
        remove: function(fav_id) {
            var tmp = FavIds.get(),
                fav_id_index = tmp.indexOf(fav_id.toString());
            if(fav_id_index >= 0) { tmp.splice(fav_id_index, 1); }
            document.cookie = 'fav_ids=' + tmp.join(',');
        }
    }


    // ----
    
    var max_per_tag = 5;
    return function setup (tags, callback) {
        loadAllPhotos(tags, max_per_tag, function (err, items) {
            if (err) { return callback(err); }

            each(items.map(renderPhoto), imageAppender('photos'));
            callback();
        });
    };
}(jQuery));
