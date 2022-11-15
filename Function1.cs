using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Data.SqlClient;
using System.Collections.Generic;
namespace AzureFunction
{
    public static class GetCustomerInfoFunction
    {
        [FunctionName("GetCustomerInfo")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");
            string id = req.Query["id"];
            var results = new List<string>();
            var str = Environment.GetEnvironmentVariable("SqlConnection");
            var reg = Environment.GetEnvironmentVariable("Region");
            using (SqlConnection conn = new SqlConnection(str))
            {
                conn.Open();
                var text = "SELECT id, Name, Email " +
                           "FROM [dbo].[Customers] " +
                           $"Where id={id}";
                using (SqlCommand cmd = new SqlCommand(text, conn))
                {
                    // Execute the command and log the # rows affected.
                    var reader = await cmd.ExecuteReaderAsync();
                    while (reader.Read())
                    {
                        results.Add(reader.GetString(1));
                        results.Add(reader.GetString(2));
                        results.Add(reg);
                    }
                }
            }
            return new OkObjectResult(results);
        }
    }
}