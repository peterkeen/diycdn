# DIY CDN

This is a Rails app that will eventually power my tiny DIY content distribution network. Follow along if you'd like.


## setting up a new cache node

* create proxy in cdn app
* create dns entry
* create vps
* `curl -H 'Authorization: Bearer <proxy api key>' https://cdn.hostname/setup | sudo bash`

## scripts

* `setup` install nginx, create update cron
* `update` one-minute cron, update certificates and config with last-updated-at. if there are updates, extract new certificates file, restart nginx

## Changelog

### 2018-08-26 (evening)

Switched to production LE and set up corastreetpress.com. Everything seems to be working as expected.

### 2018-08-26

App can now set up latency-based A and AAAA records for sites

Next steps:

* Use the `last_seen_at` Proxy attribute to pull proxies out of rotation that don't check in
* Switch to production LE & set up a real site

### 2018-08-25

These things are now working:

* creating or updating a site's domain list will generate a LetsEncrypt certificate
* nginx config generation
* setup script (install nginx, create update `curl | bash` shim, set up cron)
* update script (download certificates and nginx config, restart nginx)
* update script is a server-controlled noop unless a site or proxy has updated since the certificates zipfile was last downloaded

Next steps:

* Switch to production LetsEncrypt
* Teach app how to set up proxies as geo-latency A and AAAA records for labels in domain_list for each site
* Set up a real site

## TODO

* coordinate proxy admin with capistrano
* investigate SSH certificate authority
