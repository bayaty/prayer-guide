#!/usr/bin/env bash
# Build the Flutter web app and deploy it to the Beelink.
#
# WHY THE CACHE BUSTING
# The site sits behind Cloudflare. Its edge cached main.dart.js and kept
# serving an old build after a deploy, so a shipped fix looked like it had
# never landed. Origin headers alone do not evict an object already at the
# edge, and there is no API token here to purge it.
#
# So every deploy writes a NEW filename, main.<hash>.js, which the edge has
# never seen and therefore cannot have cached. index.html and the bootstrap
# are served no-cache, so the new name is picked up immediately.
set -euo pipefail

cd "$(dirname "$0")/.."

REMOTE="${PRAYER_WEB_REMOTE:-beelink}"
REMOTE_DIR="${PRAYER_WEB_DIR:-~/sites/prayerguide/app}"

echo "==> building"
# The coffee link is passed at build time so it is not committed in
# the widget source. Override with COFFEE_LINK=... to test.
COFFEE_LINK="${COFFEE_LINK:-https://buy.stripe.com/7sYaEZ91DeyB2cT371ao800}"
flutter build web --release --base-href /app/ --dart-define=COFFEE_LINK="$COFFEE_LINK"

cd build/web

# Content hash of the app bundle. A build that changes nothing keeps its
# name, so an unchanged deploy does not needlessly bust the cache.
HASH="$(md5sum main.dart.js | cut -c1-10)"
NEW="main.$HASH.js"

echo "==> fingerprinting main.dart.js -> $NEW"
mv main.dart.js "$NEW"

# Flutter references the entrypoint from its bootstrap and service worker.
# Both must point at the new name or the page loads nothing.
for f in flutter_bootstrap.js flutter_service_worker.js index.html; do
  [ -f "$f" ] && sed -i "s|main\.dart\.js|$NEW|g" "$f"
done

# Fail loudly rather than deploying a page that references a missing file.
if ! grep -q "$NEW" flutter_bootstrap.js; then
  echo "✗ bootstrap does not reference $NEW; refusing to deploy" >&2
  exit 1
fi
if grep -rq "main\.dart\.js" flutter_bootstrap.js flutter_service_worker.js index.html; then
  echo "✗ a stale main.dart.js reference survived; refusing to deploy" >&2
  exit 1
fi

echo "==> uploading to $REMOTE:$REMOTE_DIR"
rsync -az --delete ./ "$REMOTE:$REMOTE_DIR/"

echo "==> verifying what the public URL actually serves"
URL="https://prayerguide.y-m-a-b.com/app"
sleep 3

code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 45 "$URL/")"
[ "$code" = "200" ] || { echo "✗ / returned $code" >&2; exit 1; }

# The bundle is what actually changes; check the served copy matches what
# was just built, not merely that something returns 200.
served="$(curl -s --max-time 90 "$URL/$NEW" | md5sum | cut -c1-12)"
local_sum="$(md5sum "$NEW" | cut -c1-12)"
if [ "$served" != "$local_sum" ]; then
  echo "✗ served bundle $served does not match built $local_sum" >&2
  exit 1
fi

echo "✓ deployed and verified: $URL/ is serving $NEW"
