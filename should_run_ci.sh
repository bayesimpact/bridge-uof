BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Always run CI in master.
if [ "$BRANCH" != "master" ]; then
  # Do not run CI if the branch doesn't exist anymore.
  if [ -z "$(git ls-remote --heads origin "$BRANCH")" ]; then
    echo "Branch doesn't exist anymore - skipping tests ..."
    touch skip-tests
    exit
  fi

  # Do not run CI if the branch has already been updated.
  if [ "$(git ls-remote --heads origin "$BRANCH" | cut -f1)" != "$(git rev-parse HEAD)" ]; then
    echo "Branch is no longer up-to-date - skipping tests ..."
    touch skip-tests
    exit
  fi
fi
