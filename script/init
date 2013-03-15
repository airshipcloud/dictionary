#!/bin/sh

echo ""
echo "========================================="
echo "Initializing database..."
echo ""

psql -U postgres -f ./db/roles.sql
createdb -U airship_dict airship_dict
psql -U airship_dict -f ./db/schema.sql

echo ""
echo "DONE initializing"
echo ""
