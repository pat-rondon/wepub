#!/bin/bash

# Parse parameters

USAGE="Usage: $0 output.epub [Wikipedia URL list]"

if [ $# -gt 0 ] && ( [ $1 = "-h" ] || [ $1 = "--help" ] ); then
    echo $USAGE
    exit 0
fi

if [ $# -lt 2 ]; then
    echo "Too few arguments."
    echo $USAGE
    exit 1
fi

function dieIfFailed {
    if [ $? -ne 0 ]; then
        echo "Failure: $1"
        exit $2
    fi
}

BASE=`basename "$1" ".epub"`
OUTFILE="$BASE.epub"
TMPDIR=`mktemp -d -t wepub`
TMP="$TMPDIR/wepub.html"

shift

# Fetch URLs and merge contents into a single HTML file

echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" dir="ltr" xmlns="http://www.w3.org/1999/xhtml">
<body>' > $TMP

for url in $@; do
    curl $url -s -o - | w3hxselect "#content" >> $TMP
    dieIfFailed "Could not download $url" 2
done

echo '</html></body>' >> $TMP

# Convert into EPUB

ebook-convert $TMP $OUTFILE \
    --no-default-epub-cover \
    --smarten-punctuation \
    --level1-toc '//*[@class="firstHeading"]' \
    --output-profile kindle \
    --max-levels 0 \
    --authors "Wikipedia" \
    --title ""

dieIfFailed "Could not convert to EPUB." 3