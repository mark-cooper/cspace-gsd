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

Review and use `upload.sh` for importing the data into CollectionSpace (requires `csible` config).

Done =)

License
---

The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---
