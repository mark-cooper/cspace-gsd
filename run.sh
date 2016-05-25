#!/bin/bash

# setup db and run migrations
rake db:drop
rake db:create
rake db:migrate

# load gsd data (must be added to db/data directory)
rake csv:seed[material,db/data/materials.csv]
rake csv:seed[material_composition,db/data/material2composition.csv]
rake csv:seed[material_form,db/data/material2form.csv]
rake csv:seed[material_process,db/data/material2process.csv]
rake csv:seed[material_property,db/data/material2property.csv]
rake csv:seed[material_map,db/material_maps.csv]
rake csv:seed[concept,db/data/concepts.csv]
rake csv:seed[vendor,db/data/vendors.csv]

# export records
rake export:all[material]
rake export:all[concept]
rake export:all[vendor]

# create csv for concepts and vendor contacts, persons
rake export:concept_hierarchy
rake export:vendor_contacts
rake export:vendor_persons

# done =)
