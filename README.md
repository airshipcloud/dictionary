WordNet Dictionary
==================

The dictionary service provides a JSON API for looking up words in WordNet
and matching the against a particular corpus.

## Requirements

PostgreSQL 9.1+
Erlang R15B03

[See Zephyr Install Guide](https://github.com/airships/zephyr/wiki/Install)


## Setup

```bash
# initialize the database
make setup
# start the service
script/dictionary console
```

## Querying

```bash
curl -v http://localhost:10001/tags/software%20development
```
