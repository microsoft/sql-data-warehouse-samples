namespace Microsoft.Azure.SqlDataWarehouse.Management
{
    using System;

    /// <summary>
    /// Represents an Azure SQL Data Warehouse (http://aka.ms/sqldw) instance. 
    /// </summary>
    public class Instance
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Instance"/> class.
        /// </summary>
        public Instance()
        {
        }

        /// <summary>
        /// Gets or sets the database name for the <see cref="Instance"/>.
        /// </summary>
        public string Database { get; set; }

        /// <summary>
        /// Gets or sets the location/region for the <see cref="Instance"/>.
        /// </summary>
        public string Location { get; set; }

        /// <summary>
        /// Gets or sets the Resouce Group for the <see cref="Instance"/>.
        /// </summary>
        public string ResourceGroup { get; set; }

        /// <summary>
        /// Gets or set the server name for the <see cref="Instance"/>.
        /// </summary>
        public string Server { get; set; }

        /// <summary>
        /// Gets or sets the Subscription Id for the <see cref="Instance"/>.
        /// </summary>
        public Guid SubscriptionId { get; set; }
    }
}