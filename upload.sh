#!/bin/bash

# note: adjust path to csible as appropriate
rm -rf ../csible/imports/cataloging
rm -rf ../csible/imports/concept
rm -rf ../csible/imports/material
rm -rf ../csible/imports/person
rm -rf ../csible/imports/vendor

cp -r exports/cataloging ../csible/imports
cp -r exports/concept    ../csible/imports
cp -r exports/material   ../csible/imports
cp -r exports/vendor     ../csible/imports

cd ../csible
# generate the person authority records
mkdir imports/person
rake template:cs:persons:process[imports/vendor/vendor_persons.csv,imports/person]

# to import them to the shared authority server (SAS) use:
CONCEPTS_MC="conceptauthorities/urn:cspace:name(materialclassification_shared)/items"
MATERIALS_LM="materialauthorities/urn:cspace:name(material_shared)/items"
ORGS_LO="orgauthorities/urn:cspace:name(organization_shared)/items"
PERSONS_LP="personauthorities/urn:cspace:name(person_shared)/items"

rake cs:post:directory[$CONCEPTS_MC,imports/concept]
rake cs:post:directory[$MATERIALS_LM,imports/material]
rake cs:post:directory[$ORGS_LO,imports/vendor]
rake cs:post:directory[$PERSONS_LP,imports/person]

# generate and import the concept relationship hierarchy records
rake cs:relate:authorities[$CONCEPTS_MC,concepts,imports/concept/concept_hierarchy.csv]

# generate and import the organization contact records
rake cs:relate:contacts[$ORGS_LO,imports/vendor/vendor_contacts.csv]

# import the cataloging records to the GSD client instance
# update domain in nrb/config.rb and run.sh again!
# rake cs:post:directory[collectionobjects,imports/cataloging]

exit 0
