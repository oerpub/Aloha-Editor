define(function(){
    return {
        commonprefix: function (m){
            if(!(m && m.length)) return '';
            var li = m.slice(); // copy it
            li.sort(); // in place sort
            s1 = li[0]
            s2 = li.pop();
            for (var i in s1){
                c = s1[i];
                if (c != s2[i]) {
                    return s1.slice(0, i);
                }
            }
            return s1;
        },
        
        isabs: function (s){
            return s.length && (s[0] == '/');
        },
        
        normpath: function (path){
            var slash = '/', dot = '.';
            if(path == '') return dot;
            var initial_slashes = (path.length && (path[0] === '/'));
            var new_comps = [],
                comps = path.split('/');
            for (var i in comps){
                comp = comps[i];
                if (comp === '' || comp === '.') continue;
                if (comp !== '..' || (!initial_slashes && !new_comps.length) || 
                    (new_comps.length && new_comps[new_comps.length-1] === '..')){
                    new_comps.push(comp);
                } else if (new_comps.length) {
                    new_comps.pop();
                }
            }
            comps = new_comps;
            path = comps.join(slash);
            if (initial_slashes){
                path = '/' + path;
            }
            return path || dot;
        },
        
        abspath: function (path){
            if (!this.isabs(path)) {
                // Since this is in the web env there is no cwd. ASsume /
                return this.normpath('/' + path);
            }
            return this.normpath(path);
        },
        
        relpath: function (path, start){
            var start_list = [],
                c1 = this.abspath(start).split('/'),
                x, i;
            for (i in c1){
                x = c1[i];
                if(x) start_list.push(x);
            }
        
            var path_list = [],
                c2 = this.abspath(path).split('/');
            for (i in c2){
                x = c2[i];
                if(x) path_list.push(x);
            }
        
            // Work out how much of the filepath is shared by start and path.
            var prefix = this.commonprefix([start_list, path_list]),
                i = prefix.length,
                j;
        
            var rel_list = [];
            for (j=0; j < start_list.length - i; j++) rel_list.push('..');
            for (j=i; j<path_list.length; j++) rel_list.push(path_list[j]);
            
            if(!rel_list.length) return '.'
            return rel_list.join('/');
        },
        
        dirname: function (path){
            var i = path.lastIndexOf('/') + 1,
                head = path.slice(0, i);
            if (head !== '/'){
                return head.replace(/\/+$/g, '');
            }
            return head;
        }
    };
});
