namespace Microsoft.Azure.SqlDataWarehouse.Management
{
    using System;

    public static class ExtensionMethods
    {
        public static void ThrowIfNull(this object value)
        {
            if (value == null)
            {
                throw new ArgumentNullException();
            }
        }

        public static void ThrowIfNullOrEmpty(this string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                throw new ArgumentNullException();
            }
        }
    }
}
