#!/bin/bash

echo "Creating schemata from templates..."

rm -f schema/*

for schema_tmpl in $(ls schema_templates/*.ldif); do
    echo $schema_tmpl
    sed 's/${SCHEMADN}/CN=Schema,CN=Configuration,DC=podewitz,DC=de/g' \
	${schema_tmpl} > schema/$(basename ${schema_tmpl})
done

