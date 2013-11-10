#!/bin/bash
if [[ -f $DOKKU_ROOT/HIPACHE_REDIS ]]; then
	HIPACHE_REDIS_URL=$(cat $DOKKU_ROOT/HIPACHE_REDIS)
else
	HIPACHE_REDIS_URL=127.0.0.1
fi

if [[ -f $DOKKU_ROOT/HIPACHE_REDIS_PORT ]]; then
	HIPACHE_REDIS_PORT=$(cat $DOKKU_ROOT/HIPACHE_REDIS_PORT)
else
	HIPACHE_REDIS_PORT=6379
fi

function redis {
	redis-cli -h $HIPACHE_REDIS_URL -p $HIPACHE_REDIS_PORT $*
}

function hipache_delete {
	redis del frontend:$1 >/dev/null
}

function hipache_frontend {
	redis rpush frontend:$1 $2 >/dev/null
}

function hipache_backend {
	redis rpush frontend:$1 $2 >/dev/null
}

function hipache_info {
	redis lrange frontend:$1 0 -1
}

function hipache_configure {
	echo $1 > $DOKKU_ROOT/HIPACHE_REDIS
}

function app_hostname {
		PORT=$(< "$DOKKU_ROOT/$1/PORT")	
		VHOST=$(< "$DOKKU_ROOT/VHOST")
		SUBDOMAIN=${1/%\.${VHOST}/}
		if [[ "$1" == *.* ]] && [[ "$SUBDOMAIN" == "$APP" ]]; then
			hostname="${1/\//-}"
		else
			hostname="${1/\//-}.$VHOST"
  	fi
}

