using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Data.SqlClient;
using Microsoft.Azure.Services.AppAuthentication;

namespace FunctionApi
{
    public static class Function1
    {
        [FunctionName("Function1")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req, ExecutionContext context,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            var config = context.BuildConfiguraion();
            var provider = new AzureServiceTokenProvider();
            var accessToken = provider.GetAccessTokenAsync("https://database.windows.net/").Result;

            log.LogInformation($"AccessToken: {accessToken}");

            SqlConnectionStringBuilder csb = new SqlConnectionStringBuilder();
            csb.DataSource = config["SQLDataSource"];
            csb.InitialCatalog = "def_db";
            log.LogInformation($"ConnectionString: {csb.ConnectionString}");

            using (SqlConnection conn = new SqlConnection(csb.ConnectionString))
            {
                conn.AccessToken = accessToken;
                conn.Open();

                log.LogInformation($"Connected to Database");

                var text = "SELECT 1";
                using (SqlCommand cmd = new SqlCommand(text, conn))
                {
                    // Execute the command and log the # rows affected.
                    var rows = await cmd.ExecuteNonQueryAsync();
                    log.LogInformation($"{rows} rows were updated");
                }
            }

            return new OkObjectResult("OK");
        }
    }
}
