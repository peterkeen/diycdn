# DIY CDN

This is a Rails app that will eventually power my tiny DIY content distribution network. Follow along if you'd like.


## setting up a new cache node

* create proxy in cdn app
* create dns entry
* create vps
* `curl -H 'Authorization: Bearer <proxy api key>' https://cdn.hostname/setup | sudo bash`

## scripts

* `setup` install nginx, create update cron
* `update` one-minute cron, update certificates and config with last-updated-at. if there are updates, extract new certificates fil, restart nginx
