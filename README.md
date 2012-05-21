# Passing the webadmin and neo4j-rest-api for Heroku

- clone the template

        git clone http://github.com:tbaum/neo4j-pass-through.git

- create a Heroku-App, add neo4j-addon

        heroku create your-app-name --stack cedar
        heroku addons:add neo4j --app your-app-name
        git push git@heroku:your-app-name.git master


- further reading
  - http://www.neo4j.org
  - https://devcenter.heroku.com/articles/neo4j

