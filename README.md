# google-domains-dyn-dns-updater

Updater for google domains dynamic dns

# Installation

`sudo make install`

Add the example configs:

`mkdir ~/.google_domains_dynamic/config`

`cp example_config ~/.google_domains_dynamic/config`

`$EDITOR ~/.google_domains_dynamic/config`

You can also use an alternative system wide path to the config if you wish:
`/etc/google_domains_dynamic/config`

Of note, settings in `$HOME/.google_domains_dynamic/config` will override the system wide settings.

## Usage

Invoking `gddd_updater` will update your IP if it has changed, and will do nothing if not.

## Example crontab

Invoke it daily from cron:

```
0 0 * * * /usr/local/bin/gddd_updater
```
