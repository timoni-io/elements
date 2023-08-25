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
	# set the backend
	set req.backend_hint = d.backend("{{BackendDomain}}");

	unset req.http.Cookie;
}

sub vcl_backend_response {

	# if req.url ~ ""

	unset beresp.http.Cache-Control;
	set beresp.http.Cache-Control = "public";

	unset beresp.http.Cookie;
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
