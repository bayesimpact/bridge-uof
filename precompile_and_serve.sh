#!/bin/bash

# Exit on first error.
set -e

# Precompile assets.
if [ "${RAILS_ENV}" == "production" ]; then
  rake assets:precompile
fi

# Serve.
rails server $@
