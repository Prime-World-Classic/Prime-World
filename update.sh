#!/bin/bash
exec 2>&1

WD=$(pwd)
TEST_DIR="${WD}/Game"
cd "$TEST_DIR" 2>/dev/null || WD="$WD/.."

GAME_DIR="${WD}/Game"
GAME_REMOTE="https://github.com/Prime-World-Classic/PWCGitUpdates-test.git"
LAUNCHER_DIR="${WD}/Launcher/content"
LAUNCHER_REMOTE="https://github.com/Prime-World-Classic/content-test.git"

echo "Updating Game..."

cd "$GAME_DIR" || exit 12

if [ ! -d .git ]; then
    git init
    echo "Game repo has been initialized"
else
    echo "Game repo is already exists, no need to init"
fi

git remote add origin "$GAME_REMOTE" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Game repo remote has been added"
else
    git remote set-url origin "$GAME_REMOTE"
    echo "Game repo remote has been updated to $GAME_REMOTE"
fi

echo "Updating game files"
git fetch --all --progress
git reset --hard origin/main

if [ $? -eq 0 ]; then
    echo "Successfully updated game files"
else
    echo "Game update finished with errors"
    exit 1
fi





echo "Updating launcher"
cd "$LAUNCHER_DIR" || exit 13

if [ ! -d .git ]; then
    git init
    echo "Launcher repo has been initialized"
else
    echo "Launcher repo is already exists, no need to init"
fi

git remote add origin "$LAUNCHER_REMOTE" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Launcher repo remote has been added"
else
    git remote set-url origin "$LAUNCHER_REMOTE"
    echo "LAUNCHER repo remote has been updated to $LAUNCHER_REMOTE"
fi

echo "Updating launcher files"
git fetch --all --progress
git reset --hard origin/main

if [ $? -eq 0 ]; then
    echo "Successfully updated game files"
else
    echo "Game update finished with errors"
    exit 1
fi

echo "Update finished. Please restart the game"
exit 0
