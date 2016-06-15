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

```bash
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

# to import them use (examples require "jq"):
CONCEPTS_MC="conceptauthorities/urn:cspace:name(materialclassification)/items"
MATERIALS_LM="materialauthorities/urn:cspace:name(material)/items"
ORGS_LO="orgauthorities/urn:cspace:name(organization)/items"
PERSONS_LP="personauthorities/urn:cspace:name(person)/items"

rake cs:post:directory[collectionobjects,imports/cataloging]
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