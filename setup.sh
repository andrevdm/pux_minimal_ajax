# mkdir project_name
# cd project_name
# pulp init
# npm init

bower install purescript-prelude --save
bower install purescript-console --save
bower install purescript-pux --save
bower install purescript-react --save
bower install purescript-globals --save
bower install purescript-dom --save
bower install purescript-affjax --save

npm install --save react
npm install --save react-dom

pulp browserify --optimise  > index.js
