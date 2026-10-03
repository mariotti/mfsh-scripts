# jq recipes

Notes on handling a `QUESTIONS.json` file with `jq`. These are recipes, not a
runnable script — they need editing (field names, filenames) for whatever
you're working on at the time.

Tested against jq 1.7.1; noted below wherever a newer jq made the original
recipe (written against jq ~1.5) obsolete.

## Generic recursive walk

**Original (jq < 1.6):** `walk/1` didn't exist yet, so it had to be
hand-defined. Apply a filter `f` to every object/array/atom, recursively:

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

**jq 1.6+:** `walk/1` is now a built-in — drop the `def` entirely and just
call `walk(f)` directly. The hand-rolled version above still works (it just
shadows the built-in), kept here for jq < 1.6 or as a reference for how it
works.

## Rename a field (deep)

Rename `name` -> `title` wherever it occurs, using `walk`:

**jq 1.6+ (current):**

```sh
jq '. |= walk(
      if type == "object"
      then with_entries(if .key == "name" then .key |= sub("name";"title") else . end)
      else .
      end)' QUESTIONS.json
```

**jq < 1.6:** paste the custom `walk` def above it, same as the original
recipe:

```sh
cat QUESTIONS.json | jq '.' | jq '
<walk def here>
(. |= walk(
      if type == "object"
      then with_entries(if .key == "name" then .key |= sub("name";"title") else . end)
      else .
      end))'
```

Ref: <https://stackoverflow.com/questions/31756724/transforming-the-name-of-key-deeper-in-the-json-structure-with-jq>

## Add a key/value into a nested array of objects

Still the right way to do this; no newer builtin replaces it.

```sh
cat QUESTIONS.json | jq '.TechQuestions.category[].question[] += {"codefile": "to configure"}'
```

Ref: <https://stackoverflow.com/questions/43148797/jq-how-to-add-an-object-key-value-in-a-nested-json-tree-with-arrays>

## Merge in a `tree -J` listing

Build a `codetree` from directory listings and merge language/filename info
into each question. Still current:

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
sort_by(.id | scan("[0-9]+$") | tonumber)
```

Note: the original cookbook recipe used `scan("[0-9]*$")` (`*` not `+`).
With jq 1.7.1 that throws `Expected JSON value (while parsing '')` — the
`*` lets the regex also match a zero-width string right at the end,
so `scan` yields an extra `""` that `tonumber` can't parse. Use `+`.

Ref: <https://github.com/jqlang/jq/wiki/Cookbook#sort-by-numeric-values-extracted-from-text>
(the old `stedolan/jq` org was renamed to `jqlang/jq` after the original
maintainer stepped back; links above redirect but point there directly.)
