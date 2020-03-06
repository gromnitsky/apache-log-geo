    $ cat test/data/* | awk '/style.css/ {print $1}' | xargs ./mmdb-lookup | json -c 'this.country_code === "PL"' -a ip | xargs -n1 -I@ grep -h ^@ test/data/*
