# apache-log-geo

An offline GeoIP CLI filter for Apache (common, combined) logs. It's
like grep but with a knowledge about what data an ip holds. Supa
handy!

Reqs:

* ruby
* `dnf install libmaxminddb-devel geolite2-city`

If there's no geolite2-city pkg (that contains `GeoLite2-City.mmdb`
file) for your system, register on MaxMind's website, get a license
key & install geoipupdate to fetch the db file.

## Install

    gem install apache-log-geo

By default it uses the official maxmind-db gem, but if you also do

    gem install geoip2_c

the pkg will automatically load it in maxmind-db stead. geoip2_c is a
C extension that works *much* faster.

## Usage

The pkg contains 2 CLI utils only. There's no reusable library code.

### apache-log-geo

This is a simple grep-like filter:

~~~
$ ./apache-log-geo -h
Usage: apache-log-geo [-d GeoLite2-City.mmdb] [-v] [--key val ...]
    -d path                          maxmind db file
    -v                               invert match
        --city regexp
        --country regexp
        --cc str                     2 letter country code
        --eu                         is an EU member?
        --continent regexp
        --postcode regexp
        --sub regexp                 subdivisions
~~~

It tries to guess the location of the .mmdb file, thus specifying `-d`
opt is often unnecessary.

Options that begin with `--` constitute test conditions for a
filter. Conditions are anded. Unlike grep, specifying no conditions is
not an error--the util will act as a pass through for each valid log
line that starts with an ip address that is known to the GeoLite2 db.

`--cc` opt is special: it doesn't take a regexp, but a 2-letter codes
separated with `|`.

#### Examples

A pass through:

~~~
$ head -2 test/access.log | ./apache-log-geo
52.18.122.238 - - [06/Mar/2020:00:02:00 -0500] "GET /~alex/doc/bunz%2Cmercedes__school-will-never-end/ HTTP/1.1" 200 17133 "-" "Apache-HttpClient/4.3.6 (java 1.5)"
54.174.110.177 - - [06/Mar/2020:00:03:10 -0500] "GET /~alex/doc/bunz%2Cmercedes__school-will-never-end/ HTTP/1.1" 200 17133 "-" "Ruby"
~~~

Filter by a country code:

~~~
$ head -2 test/access.log | ./apache-log-geo --cc ie
52.18.122.238 - - [06/Mar/2020:00:02:00 -0500] "GET /~alex/doc/bunz%2Cmercedes__school-will-never-end/ HTTP/1.1" 200 17133 "-" "Apache-HttpClient/4.3.6 (java 1.5)"

$ cat test/access.log | ./apache-log-geo --cc 'ie|de' | wc -l
11
~~~

### mmdb-lookup

Renders data about ip addresses in newline-delimited json (default) or
in a shell script ready format:

~~~
$ ./mmdb-lookup -h
Usage: mmdb-lookup [-d GeoLite2-City.mmdb] [-f fmt] ip...
    -d path                          maxmind db file
    -f fmt                           output format: json, shell
~~~

IPs can come either from the command line or from the stdin. Again,
`-d` is optional.

#### Examples

Evaluate a printed shell code:

~~~
$ (eval `./mmdb-lookup 5.1.0.0 -f shell`; echo $subdivisions)
Kyiv City
~~~

Replicate `apache-log-geo` util--print only the requests from the Irish
(the example requires `npm -g json`):

    $ cat test/access.log | ./mmdb-lookup | json -g -c 'this.country_code == "IE"' -a ip | grep -h -f - test/access.log

## Exit status

* 0 -- some lines were matched
* 1 -- nothing was matched
* 2 -- an error occurred

## License

MIT.
