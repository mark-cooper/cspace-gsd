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

# to import them use:
rake cs:post:directory[conceptauthorities/$csid/items,imports/concept]
rake cs:post:directory[materialauthorities/$csid/items,imports/material]
rake cs:post:directory[orgauthorities/$csid/items,imports/vendor]
rake cs:post:directory[personauthorities/$csid/items,imports/person]
# replacing $csid with a valid csid from the target cspace instance

# generate and import the concept relationship hierarchy records
rake cs:relate:authorities[conceptauthorities/$csid/items,concepts,imports/concept/concept_hierarchy.csv]

# generate and import the organization contact records
rake cs:relate:contacts[orgauthorities/$csid/items,imports/vendor/vendor_contacts.csv]
```

Done =)

License
---

The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---