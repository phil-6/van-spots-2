// supercluster@8.0.1 downloaded from https://ga.jspm.io/npm:supercluster@8.0.1/index.js

import t from"kdbush";const s={minZoom:0,maxZoom:16,minPoints:2,radius:40,extent:512,nodeSize:64,log:false,generateId:false,reduce:null,map:t=>t};const e=Math.fround||(t=>s=>{t[0]=+s;return t[0]})(new Float32Array(1));const o=2;const n=3;const i=4;const r=5;const c=6;class Supercluster{constructor(t){this.options=Object.assign(Object.create(s),t);this.trees=new Array(this.options.maxZoom+1);this.stride=this.options.reduce?7:6;this.clusterProps=[]}load(t){const{log:s,minZoom:o,maxZoom:n}=this.options;s&&console.time("total time");const i=`prepare ${t.length} points`;s&&console.time(i);this.points=t;const r=[];for(let s=0;s<t.length;s++){const o=t[s];if(!o.geometry)continue;const[n,i]=o.geometry.coordinates;const c=e(lngX(n));const h=e(latY(i));r.push(c,h,Infinity,s,-1,1);this.options.reduce&&r.push(0)}let c=this.trees[n+1]=this._createTree(r);s&&console.timeEnd(i);for(let t=n;t>=o;t--){const e=+Date.now();c=this.trees[t]=this._createTree(this._cluster(c,t));s&&console.log("z%d: %d clusters in %dms",t,c.numItems,+Date.now()-e)}s&&console.timeEnd("total time");return this}getClusters(t,s){let e=((t[0]+180)%360+360)%360-180;const o=Math.max(-90,Math.min(90,t[1]));let i=180===t[2]?180:((t[2]+180)%360+360)%360-180;const c=Math.max(-90,Math.min(90,t[3]));if(t[2]-t[0]>=360){e=-180;i=180}else if(e>i){const t=this.getClusters([e,o,180,c],s);const n=this.getClusters([-180,o,i,c],s);return t.concat(n)}const h=this.trees[this._limitZoom(s)];const a=h.range(lngX(e),latY(c),lngX(i),latY(o));const l=h.data;const u=[];for(const t of a){const s=this.stride*t;u.push(l[s+r]>1?getClusterJSON(l,s,this.clusterProps):this.points[l[s+n]])}return u}getChildren(t){const s=this._getOriginId(t);const e=this._getOriginZoom(t);const o="No cluster with the specified id.";const c=this.trees[e];if(!c)throw new Error(o);const h=c.data;if(s*this.stride>=h.length)throw new Error(o);const a=this.options.radius/(this.options.extent*Math.pow(2,e-1));const l=h[s*this.stride];const u=h[s*this.stride+1];const p=c.within(l,u,a);const d=[];for(const s of p){const e=s*this.stride;h[e+i]===t&&d.push(h[e+r]>1?getClusterJSON(h,e,this.clusterProps):this.points[h[e+n]])}if(0===d.length)throw new Error(o);return d}getLeaves(t,s,e){s=s||10;e=e||0;const o=[];this._appendLeaves(o,t,s,e,0);return o}getTile(t,s,e){const o=this.trees[this._limitZoom(t)];const n=Math.pow(2,t);const{extent:i,radius:r}=this.options;const c=r/i;const h=(e-c)/n;const a=(e+1+c)/n;const l={features:[]};this._addTileFeatures(o.range((s-c)/n,h,(s+1+c)/n,a),o.data,s,e,n,l);0===s&&this._addTileFeatures(o.range(1-c/n,h,1,a),o.data,n,e,n,l);s===n-1&&this._addTileFeatures(o.range(0,h,c/n,a),o.data,-1,e,n,l);return l.features.length?l:null}getClusterExpansionZoom(t){let s=this._getOriginZoom(t)-1;while(s<=this.options.maxZoom){const e=this.getChildren(t);s++;if(1!==e.length)break;t=e[0].properties.cluster_id}return s}_appendLeaves(t,s,e,o,n){const i=this.getChildren(s);for(const s of i){const i=s.properties;i&&i.cluster?n+i.point_count<=o?n+=i.point_count:n=this._appendLeaves(t,i.cluster_id,e,o,n):n<o?n++:t.push(s);if(t.length===e)break}return n}_createTree(s){const e=new t(s.length/this.stride|0,this.options.nodeSize,Float32Array);for(let t=0;t<s.length;t+=this.stride)e.add(s[t],s[t+1]);e.finish();e.data=s;return e}_addTileFeatures(t,s,e,o,i,c){for(const h of t){const t=h*this.stride;const a=s[t+r]>1;let l,u,p;if(a){l=getClusterProperties(s,t,this.clusterProps);u=s[t];p=s[t+1]}else{const e=this.points[s[t+n]];l=e.properties;const[o,i]=e.geometry.coordinates;u=lngX(o);p=latY(i)}const d={type:1,geometry:[[Math.round(this.options.extent*(u*i-e)),Math.round(this.options.extent*(p*i-o))]],tags:l};let g;g=a||this.options.generateId?s[t+n]:this.points[s[t+n]].id;void 0!==g&&(d.id=g);c.features.push(d)}}_limitZoom(t){return Math.max(this.options.minZoom,Math.min(Math.floor(+t),this.options.maxZoom+1))}_cluster(t,s){const{radius:e,extent:n,reduce:c,minPoints:h}=this.options;const a=e/(n*Math.pow(2,s));const l=t.data;const u=[];const p=this.stride;for(let e=0;e<l.length;e+=p){if(l[e+o]<=s)continue;l[e+o]=s;const n=l[e];const d=l[e+1];const g=t.within(l[e],l[e+1],a);const f=l[e+r];let m=f;for(const t of g){const e=t*p;l[e+o]>s&&(m+=l[e+r])}if(m>f&&m>=h){let t=n*f;let h=d*f;let a;let _=-1;const M=((e/p|0)<<5)+(s+1)+this.points.length;for(const n of g){const u=n*p;if(l[u+o]<=s)continue;l[u+o]=s;const d=l[u+r];t+=l[u]*d;h+=l[u+1]*d;l[u+i]=M;if(c){if(!a){a=this._map(l,e,true);_=this.clusterProps.length;this.clusterProps.push(a)}c(a,this._map(l,u))}}l[e+i]=M;u.push(t/m,h/m,Infinity,M,-1,m);c&&u.push(_)}else{for(let t=0;t<p;t++)u.push(l[e+t]);if(m>1)for(const t of g){const e=t*p;if(!(l[e+o]<=s)){l[e+o]=s;for(let t=0;t<p;t++)u.push(l[e+t])}}}}return u}_getOriginId(t){return t-this.points.length>>5}_getOriginZoom(t){return(t-this.points.length)%32}_map(t,s,e){if(t[s+r]>1){const o=this.clusterProps[t[s+c]];return e?Object.assign({},o):o}const o=this.points[t[s+n]].properties;const i=this.options.map(o);return e&&i===o?Object.assign({},i):i}}function getClusterJSON(t,s,e){return{type:"Feature",id:t[s+n],properties:getClusterProperties(t,s,e),geometry:{type:"Point",coordinates:[xLng(t[s]),yLat(t[s+1])]}}}function getClusterProperties(t,s,e){const o=t[s+r];const i=o>=1e4?`${Math.round(o/1e3)}k`:o>=1e3?Math.round(o/100)/10+"k":o;const h=t[s+c];const a=-1===h?{}:Object.assign({},e[h]);return Object.assign(a,{cluster:true,cluster_id:t[s+n],point_count:o,point_count_abbreviated:i})}function lngX(t){return t/360+.5}function latY(t){const s=Math.sin(t*Math.PI/180);const e=.5-.25*Math.log((1+s)/(1-s))/Math.PI;return e<0?0:e>1?1:e}function xLng(t){return 360*(t-.5)}function yLat(t){const s=(180-360*t)*Math.PI/180;return 360*Math.atan(Math.exp(s))/Math.PI-90}export{Supercluster as default};

