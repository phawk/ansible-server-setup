# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.
#
backend web1 {
    .host = "10.129.220.40";
    .port = "80";
}

# Incoming request
# can return pass or lookup (or pipe, but not used often)
sub vcl_recv {

  # set default backend as web1
  set req.backend = web1;

  # Never cache POST, PUT, PATCH or DELETE
  if (req.request != "GET") {
   return(pipe); # pass will accomplish same, but apparently more varnish handling
  }

  # Tweak accepts encoding headers
  if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
      # No point in compressing these
      remove req.http.Accept-Encoding;
    } elsif (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    } elsif (req.http.Accept-Encoding ~ "deflate" && req.http.user-agent !~ "MSIE") {
      set req.http.Accept-Encoding = "deflate";
    } else {
      # unkown algorithm
      remove req.http.Accept-Encoding;
    }
  }

  # lookup static assets in the cache
  if (req.url ~ "^/(stylesheets|images|javascripts|js|css|img|assets)" || req.url ~ "\.(png|gif|jpg|ico|txt|swf|css|js)$") {
    return(lookup);
  }

  return(lookup);
}

# called after recv and before fetch
# allows for special hashing before cache is accessed
sub vcl_hash {

}


# Before fetching from webserver
# returns pass or deliver
sub vcl_fetch {
  # Don't cache 404s 500s or anything else really.
  if (beresp.status >= 400) {
    # set beresp.ttl = 0s;
    return(hit_for_pass);
  }

  if (req.url ~ "^/(stylesheets|images|javascripts|assets)/" || req.url ~ "\.(png|gif|jpg|swf|css|js)$") {
    # removing cookie
    unset beresp.http.Set-Cookie;

    # Cache for 2 weeks
    set beresp.ttl = 2w;

    return(deliver);
  }

  # respect the backend from Rails private, no caching here
  if (beresp.http.Cache-Control ~ "private") {
    return(hit_for_pass);
  }

  # Web server set public cache
  if (beresp.http.Cache-Control ~ "public") {
      unset beresp.http.Set-Cookie;

      # unset the cache control, else the browser will keep for that long too.
      # we want to control requests.
      unset beresp.http.Cache-Control;
      set beresp.http.Cache-Control = "no-cache"; # tell client to request a new one everytime

      return(deliver);
  }

  # Will try NOT to cache by default to be safe
  return(hit_for_pass);

}

sub vcl_hit {
}

sub vcl_miss {
}

# called after fetch or lookup yields a hit
sub vcl_deliver {
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
  } else {
    set resp.http.X-Cache = "MISS";
  }
}

sub vcl_error {
}
