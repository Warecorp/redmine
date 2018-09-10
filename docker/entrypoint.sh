#!/bin/bash
set -e

[[ $DEBUG == true ]] && set -x


# init_assets() {
#   if [ ! -d /var/www/html/public/assets ]; then
#       exec bundle exec rake assets:precompile
#   fi
# }

# init_assets

case ${1} in
  app:start|app:job)

    case ${1} in
      app:start)
        exec /scripts/start_puma.sh
        ;;
      app:assets)
        exec rake assets:precompile
        ;;
    esac
    ;;
  app:help)
    echo " app:start          - Starts the server (default)"
    ;;
  *)
    exec "$@"
    ;;
esac