# jq snippets

Notes on handling a `QUESTIONS.json` file with `jq`. These are recipes, not a
runnable script — they need editing (field names, filenames) for whatever
you're working on at the time.

## Generic recursive walk

Apply a filter `f` to every object/array/atom, recursively:

```jq
def walk(f):
  . as $in
  | if type == "object" then
      reduce keys[] as $key
        ({}; . + { ($key): ($in[$key] | walk(f)) }) | f
    elif type == "array" then map(walk(f)) | f
    else f
    end;
```

## Rename a field (deep)

Rename `name` -> `title` wherever it occurs, using the `walk` above:

```sh
cat QUESTIONS.json | jq '.' | jq '
<walk def here>
(. |= walk(
      if type == "object"
      then with_entries(if .key == "name" then .key |= sub("name";"title") else . end)
      else .
      end))'
```

Ref: <http://stackoverflow.com/questions/31756724/transforming-the-name-of-key-deeper-in-the-json-structure-with-jq>

## Add a key/value into a nested array of objects

```sh
cat QUESTIONS.json | jq '.TechQuestions.category[].question[] += {"codefile": "to configure"}'
```

Ref: <http://stackoverflow.com/questions/43148797/jq-how-to-add-an-object-key-value-in-a-nested-json-tree-with-arrays>

## Merge in a `tree -J` listing

Build a `codetree` from directory listings and merge language/filename info
into each question:

```sh
echo ',{ "codetree" : ' > x.$$
tree -J python_solutions/ scala_solutions/ java_solutions/ | jq '.' >> x.$$
echo '}]' >> x.$$
echo '[' > x.pre.$$
cat x.pre.$$ QUESTIONS.json x.$$ | jq '.[0].TechQuestions.category[].question[]
    += { "CodeLanguages": .[1].codetree[].name, "codefile": .[1].codetree[].contents[].name }'
rm x.$$ x.pre.$$
```

## Sort by a numeric suffix in an id (useful for later)

```jq
sort_by(.id | scan("[0-9]*$") | tonumber)
```

Ref: <https://github.com/stedolan/jq/wiki/Cookbook#sort-by-numeric-values-extracted-from-text>
