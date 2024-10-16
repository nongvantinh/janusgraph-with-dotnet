using System;
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
            var gremlinServer = new GremlinServer("localhost", 8182); // Adjust if running in a Docker container
            var gremlinClient = new GremlinClient(gremlinServer);

            try
            {
                // Example query to retrieve vertices
                var resultSet = await gremlinClient.SubmitAsync<dynamic>("g.V().valueMap()");

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
