#!/bin/bash

# Parse parameters

USAGE="Usage: $0 [-t title] output.epub [Wikipedia URL list]"

while getopts :ht: opt; do
    case $opt in
        h) echo "$USAGE"; exit 0;;
        t) TITLE="$OPTARG";;
        ?) echo "Unrecognized option: $opt"; echo "$USAGE"; exit 1;;
    esac
done

shift $(($OPTIND - 1))

if [ "$#" -lt 2 ]; then
    echo "Too few arguments."
    echo "$USAGE"
    exit 1
fi

BASE=`basename "$1" ".epub"`
OUTFILE="$BASE.epub"
TMPDIR=`mktemp -d -t wepub`
TMP="$TMPDIR/wepub.html"

if [ -z "$TITLE" ]; then
    TITLE="$BASE"
fi

shift

# Fetch URLs and merge contents into a single HTML file

function dieIfFailed {
    if [ $? -ne 0 ]; then
        echo "Failure: $1"
        exit $2
    fi
}

echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" dir="ltr" xmlns="http://www.w3.org/1999/xhtml">
<body>' > "$TMP"

for url in $@; do
    curl "$url" -s -o - | w3hxselect "#content" >> "$TMP"
    dieIfFailed "Could not download $url" 2
done

echo '</html></body>' >> "$TMP"

# Convert into EPUB

ebook-convert "$TMP" "$OUTFILE" \
    --no-default-epub-cover \
    --smarten-punctuation \
    --level1-toc '//*[@class="firstHeading"]' \
    --output-profile kindle \
    --max-levels 0 \
    --authors "Wikipedia" \
    --title "$TITLE"

dieIfFailed "Could not convert to EPUB." 3