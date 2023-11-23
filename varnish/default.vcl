# specify the VCL syntax version to use
vcl 4.1;

# import vmod_dynamic for better backend name resolution
import dynamic;

# we won't use any static backend, but Varnish still need a default one
backend default none;

# set up a dynamic director
# for more info, see https://github.com/nigoroll/libvmod-dynamic/blob/master/src/vmod_dynamic.vcc
sub vcl_init {
        new d = dynamic.director(port = "{{BackendPort}}");
}

sub vcl_recv {
	# force the host header to match the backend (not all backends need it,
	# but example.com does)
	#set req.http.host = "{{BackendDomain}}";

	set req.backend_hint = d.backend("{{BackendDomain}}");

	if ( req.url == "/" || req.url ~ "\.(html|htm|css|js|txt|xml|svg|jpg|png)(\?[a-z0-9=\.]+)?$" || req.url ~ "^/xxprodukt/" || req.url ~ "^/wp-content/uploads/"  ) {
		unset req.http.Cookie;
		unset req.http.Authorization;
	}
}

sub vcl_backend_response {

	if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503 || beresp.status == 504) {
		set beresp.uncacheable = true;
		return (deliver);
	}

	unset beresp.http.Cache-Control;
	set beresp.http.Cache-Control = "public";

	if ( bereq.url == "/" || bereq.url ~ "\.(html|htm|css|js|txt|xml|svg|jpg|png)(\?[a-z0-9=]+)?$" || bereq.url ~ "^/xxprodukt/" || bereq.url ~ "^/wp-content/uploads/" ) {
		unset beresp.http.Cookie;
		unset beresp.http.Authorization;
	}

	set beresp.ttl = 12d;
}

sub vcl_deliver {
	unset resp.http.Via;
	unset resp.http.X-Varnish;

	if (obj.hits > 0) {
		set resp.http.X-Cache = "HIT";
	} else {
		set resp.http.X-Cache = "MISS";
	}
}
