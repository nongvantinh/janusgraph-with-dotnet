using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Gremlin.Net.Driver;
using Gremlin.Net.Driver.Remote;
using System.Text.Json;

namespace MyJanusGraphApp
{
    class Program
    {
        static async Task Main(string[] args)
        {
            // Connect to the JanusGraph instance
            var gremlinServer = new GremlinServer("janusgraph.mydatabase.com", 80);
            var gremlinClient = new GremlinClient(gremlinServer);

            try
            {
                // Example data to insert
                var persons = new List<(string Name, int Age)>
                {
                    ("Alice", 30),
                    ("Bob", 25)
                };

                foreach (var person in persons)
                {
                    var existingResult = await gremlinClient.SubmitAsync<dynamic>(
                        $"g.V().has('person', 'name', '{person.Name}').valueMap('name', 'age')"
                    );

                    if (existingResult == null || existingResult.Count == 0)
                    {
                        await gremlinClient.SubmitAsync<dynamic>(
                            $"g.addV('person').property('name', '{person.Name}').property('age', {person.Age})"
                        );
                        Console.WriteLine($"Inserted: {person.Name}, Age: {person.Age}");
                    }
                    else
                    {
                        Console.WriteLine($"{person.Name} already exists.");
                    }
                }

                var resultSet = await gremlinClient.SubmitAsync<dynamic>("g.V().valueMap('name', 'age')");

                Console.WriteLine("Result: ");
                foreach (var result in resultSet)
                {
                    string jsonString = JsonSerializer.Serialize(result, new JsonSerializerOptions { WriteIndented = true });
                    Console.WriteLine(jsonString);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
