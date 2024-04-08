# use rsync to copy files from here to xplane folder
rsync -av \
    --exclude="scripts" \
    --exclude=".git" \
    --exclude="xa-cabin.ini" \
    "/Volumes/storage/git/xa-cabin-fwl/" "/Users/dzou/X-Plane 12/Resources/plugins/FlyWithLua/Scripts/"