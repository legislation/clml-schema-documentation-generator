#!/bin/sh
echo "Generating doc for $1 with settings $2 using oXygen at $3"
exec "$3/schemaDocumentation.sh" "$1" "$2"
echo "Done generating documentation"