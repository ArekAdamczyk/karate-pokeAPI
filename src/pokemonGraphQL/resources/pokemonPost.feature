@ignore
Feature: common Pokemon GraphQL API query post
# takes query and vars as arguments
# urlBase is defined in karate-config.js

    Scenario: post
        * url urlBase
        * request { query: '#(query)', variables: '#(vars)'}
        * header Accept = 'application/json'
        * method post
        