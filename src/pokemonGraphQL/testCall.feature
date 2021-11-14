Feature: Pokemon GraphQL API Test 

    # TEST CASES:
    # Simple Pokemon API query test
    # Test pokemon_v2_pokemonspecies_aggregate query
    # Test ability - Skitty

    Scenario: Simple Pokemon API query test
        
        # define query and variables
        * text query =
        """
        query getGen3 {
            gen3_species: pokemon_v2_pokemonspecies(where: {pokemon_v2_generation: {name: {_eq: "generation-iii"}}}) {
                name
                id
            }
        }
        """
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
        * text query =
        """
        query getSpeciesCount ($genName: String) {
            speciesCount: pokemon_v2_pokemonspecies_aggregate(where: {pokemon_v2_generation: {name: {_eq: $genName}}}) {
                aggregate {
                    count
                }
            }
        }    
        """
        * def vars = { genName: '<genName>' }

        # post query
        * def getSpeciesCount = call read('classpath:src/pokemonGraphQL/resources/pokemonPost.feature')
        * match getSpeciesCount.responseStatus == 200
        # extract generation species count
        * def speciesCount = get[0] getSpeciesCount.response.data.speciesCount.aggregate.count

        # define query and variables for species query
        * text query =
        """
        query getSpecies ($genName: String) {
            species: pokemon_v2_pokemonspecies(where: {pokemon_v2_generation: {name: {_eq: $genName}}}) {
                name
            }
        }
        """
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
        # extract cute-charma bility from response and assert against expected value
       
        # define query and variables for pokemon stats
        * text query =
        """
        query getPokemonStats {
            pokemonStats: pokemon_v2_pokemonspecies(where: {name: {_eq: "skitty"}}) {
                name
                id
                pokemon_v2_generation {
                    id
                    name
                }
                pokemon_v2_pokemons {
                    pokemon_v2_pokemonabilities {
                        ability_id
                        pokemon_v2_ability {
                            name
                        }
                    }
                }
            }
        }

        """
        * def vars = null

        # post query
        * def getPokemonStats = call read('classpath:src/pokemonGraphQL/resources/pokemonPost.feature')
        * match getPokemonStats.responseStatus == 200
        # extract cute-charm ability stats
        * def cuteCharm = get[0] getPokemonStats.response.data.pokemonStats[*].pokemon_v2_pokemons[*].pokemon_v2_pokemonabilities[?(@.pokemon_v2_ability.name=='cute-charm')]
        * match cuteCharm contains { ability_id: 56 }
        