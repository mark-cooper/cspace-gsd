#!/bin/bash

# setup db and run migrations
bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:migrate

# load gsd data (must be added to db/data directory)
bundle exec rake csv:seed[material,db/data/materials.csv]
bundle exec rake csv:seed[material_composition,db/data/material2composition.csv]
bundle exec rake csv:seed[material_form,db/data/material2form.csv]
bundle exec rake csv:seed[material_process,db/data/material2process.csv]
bundle exec rake csv:seed[material_property,db/data/material2property.csv]
bundle exec rake csv:seed[material_map,db/material_maps.csv]
bundle exec rake csv:seed[concept,db/data/concepts.csv]
bundle exec rake csv:seed[vendor,db/data/vendors.csv]

# export records
bundle exec rake export:all[material]
bundle exec rake export:all[material,material_id,to_cspace_xml_cat,cataloging]
bundle exec rake export:all[concept,id]
bundle exec rake export:all[vendor]

# create csv for concepts and vendor contacts, persons
bundle exec rake export:concept_hierarchy
bundle exec rake export:vendor_contacts
bundle exec rake export:vendor_persons

# done =)
