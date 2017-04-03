#! /bin/sh
# NOTES:
# Here are defined few functions which can be useful to handle the QUESTION.json
# in case of:
# - updates
# - problems
# At present the functions cannot be used as is, they need editing.
# But they should give an idea about the possible operations on the JSON file.
#
# Useful for later:
# From: https://github.com/stedolan/jq/wiki/Cookbook#sort-by-numeric-values-extracted-from-text
# sort_by(.id|scan("[0-9]*$")|tonumber)
#
# Rename a field: used for qustion.name -> question.title
# Ref: http://stackoverflow.com/questions/31756724/transforming-the-name-of-key-deeper-in-the-json-structure-with-jq
jqrename () {
cat QUESTIONS.json | jq '.' | jq '
# Apply f to composite entities recursively, and to atoms
def walk(f):
 . as $in
 | if type == "object" then
      reduce keys[] as $key
        ( {}; . + { ($key):  ($in[$key] | walk(f)) } ) | f
  elif type == "array" then map( walk(f) ) | f
  else f
  end;
(.  |= walk(
           if type == "object"
           then with_entries( if .key == "name" then .key |= sub("name";"title") else . end)
           else .
           end))'
}
#
#
# Working! See: http://stackoverflow.com/questions/43148797/jq-how-to-add-an-object-key-value-in-a-nested-json-tree-with-arrays/43149353#43149353
jqadd () {
    cat QUESTIONS.json | jq '.TechQuestions.category[].question[] += {"codefile" : "to configure"}'
#
}
#
jqaddcodes () {
    echo ',{ "codetree" : ' > x.$$
    tree -J python_solutions/ scala_solutions/ java_solutions/ | jq '.' >> x.$$
    echo '}]' >> x.$$
    echo '[' > x.pre.$$
    #cat x.pre.$$ QUESTIONS.json x.$$
    cat x.pre.$$ QUESTIONS.json x.$$ | jq  '.[0].TechQuestions.category[].question[]
                                            += { "CodeLanguages": .[1].codetree[].name , "codefile" : .[1].codetree[].contents[].name }'
    #rm x.$$ x.pre.$$
#
}
#
jqaddwalk () {
cat QUESTIONS.json | jq '
# Apply f to composite entities recursively, and to atoms
def walk(f):
 . as $in
 | if type == "object" then
      reduce keys[] as $key
        ( {}; . + { ($key):  ($in[$key] | walk(f)) } ) | f
  elif type == "array" then map( walk(f) ) | f
  else f
  end;
(. |= walk( if type == "object" and has("question")
      then .question[] += {"codefile" : "to configure"}
      else .
      end))'
#
}
#
jqaddcodes #> QUESTIONS.json.$$
#cp QUESTIONS.json QUESTIONS.json.backup
#cp QUESTIONS.json QUESTIONS.json.backup.$$
#cp QUESTIONS.json.$$ QUESTIONS.json
#rm QUESTIONS.json.$$
