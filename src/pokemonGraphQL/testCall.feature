Feature: Pokemon GraphQL API Test 

    # TEST CASES:
    # Simple Pokemon API query test
    # Test pokemon_v2_pokemonspecies_aggregate query
    # Test ability - Skitty

    Scenario: Simple Pokemon API query test
        
        # define query and variables
        * def query = read('classpath:src/pokemonGraphQL/resources/graphQL/getGenThree.graphql')
        * def vars = null

        # post query
        * def getPokemons = call read('classpath:src/pokemonGraphQL/resources/pokemonPost.feature')
        * match getPokemons.responseStatus == 200
        # get content from response
        * def content = get getPokemons.response.data.gen3_species[*]
        
        # assert content
        # verify if response is empty
        * assert content.length > 0
        # assert types in response payload for each pokemon
        * def expectedTypes = { name: '#string', id: '#number'}
        * match each content == expectedTypes
        # is Skitty there? it should be!
        * match content contains deep { name: 'skitty'}
        # is Pikachu there? it should not!
        * match each content !contains { name: 'pikachu'}


    Scenario Outline: Test pokemon_v2_pokemonspecies_aggregate query
        # Scenario Outline example
        # tests the pokemon_v2_pokemonspecies_aggregate query by iterating over selected pokemon generation names - see Examples at the bottom of test scenario
        
        # define query and variables for species count
        * def query = read('classpath:src/pokemonGraphQL/resources/graphQL/getSpeciesCount.graphql')
        * def vars = { genName: '<genName>' }

        # post query
        * def getSpeciesCount = call read('classpath:src/pokemonGraphQL/resources/pokemonPost.feature')
        * match getSpeciesCount.responseStatus == 200
        # extract generation species count
        * def speciesCount = get[0] getSpeciesCount.response.data.speciesCount.aggregate.count

        # define query and variables for species query
        * def query = read('classpath:src/pokemonGraphQL/resources/graphQL/getSpecies.graphql')
        * def vars = { genName: '<genName>' }
        
        # post query
        * def getSpecies = call read('classpath:src/pokemonGraphQL/resources/pokemonPost.feature')
        * match getSpecies.responseStatus == 200
        # count specie names
        * def species = get getSpecies.response.data.species[*]
        * def speciesActualCount = species.length

        # assert count against actual count
        * match speciesCount == speciesActualCount


        Examples:
        | genName        |
        | generation-i   |
        | generation-ii  |
        | generation-iii |


    Scenario: Test ability - Skitty
        # example of filtering nested JSONs
        # extract cute-charm ability from response and assert against expected value
       
        # define query and variables for pokemon stats
        * def query = read('classpath:src/pokemonGraphQL/resources/graphQL/getPokemonStats.graphql')
        * def vars = null

        # post query
        * def getPokemonStats = call read('classpath:src/pokemonGraphQL/resources/pokemonPost.feature')
        * match getPokemonStats.responseStatus == 200
        # extract cute-charm ability stats
        * def cuteCharm = get[0] getPokemonStats.response.data.pokemonStats[*].pokemon_v2_pokemons[*].pokemon_v2_pokemonabilities[?(@.pokemon_v2_ability.name=='cute-charm')]
        * match cuteCharm contains { ability_id: 56 }
        