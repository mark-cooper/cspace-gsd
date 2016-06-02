# cspace-gsd

CollectionSpace data mapping for GSD.

Setup
---

Requires Ruby (`chruby` recommended). Then `bundle install`.

Instructions
---

After cloning the project create a `db/data` directory and unzip the GSD data (DTS File Share). These files are required:

```
db/data/
├── concepts.csv
├── material2composition.csv
├── material2form.csv
├── material2process.csv
├── material2property.csv
├── materials.csv
└── vendors.csv
```

To process the files simply use the provided shell script:

```
./run.sh
```

This will create and seed the (sqlite) database, then export all the records as XML and CSV. Output will go to:

```
exports/
├── concept  # material classifications
├── material # local
└── vendor   # (organization) local
```

Inside each directory are XML records. Copy these records to the [csible](https://github.com/lyrasis/csible) imports directory:

```
# note: adjust path to csible as appropriate
cp -r exports/concept  ../csible/imports
cp -r exports/material ../csible/imports
cp -r exports/vendor   ../csible/imports

cd ../csible
# generate the person authority records
mkdir imports/person
rake template:cs:persons:process[imports/vendor/vendor_persons.csv,imports/person]

# to import them use (examples require "jq"):
CONCEPTS_MC="`rake cs:get:path[conceptauthorities] | jq '.["abstract_common_list"]["list_item"][] | {uri: .uri, displayName: .displayName}' | jq -r 'select(.displayName == "Material Classifications") | .uri' | cut -c 2-`/items"

# no array for materials list_item by default
MATERIALS_LM="`rake cs:get:path[materialauthorities] | jq '.["abstract_common_list"]["list_item"] | {uri: .uri, displayName: .displayName}' | jq -r 'select(.displayName == "Local Materials") | .uri' | cut -c 2-`/items"

ORGS_LO="`rake cs:get:path[orgauthorities] | jq '.["abstract_common_list"]["list_item"][] | {uri: .uri, displayName: .displayName}' | jq -r 'select(.displayName == "Local Organizations") | .uri' | cut -c 2-`/items"

PERSONS_LP="`rake cs:get:path[personauthorities] | jq '.["abstract_common_list"]["list_item"][] | {uri: .uri, displayName: .displayName}' | jq -r 'select(.displayName == "Local Persons") | .uri' | cut -c 2-`/items"

rake cs:post:directory[$CONCEPTS_MC,imports/concept]
rake cs:post:directory[$MATERIALS_LM,imports/material]
rake cs:post:directory[$ORGS_LO,imports/vendor]
rake cs:post:directory[$PERSONS_LP,imports/person]

# generate and import the concept relationship hierarchy records
rake cs:relate:authorities[$CONCEPTS_MC,concepts,imports/concept/concept_hierarchy.csv]

# generate and import the organization contact records
rake cs:relate:contacts[$ORGS_LO,imports/vendor/vendor_contacts.csv]
```

Done =)

License
---

The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---