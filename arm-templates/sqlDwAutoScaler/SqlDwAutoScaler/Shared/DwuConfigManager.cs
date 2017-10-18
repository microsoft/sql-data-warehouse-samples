using System;
using System.IO;
using System.Linq;
using Newtonsoft.Json;

namespace SqlDwAutoScaler.Shared
{
    public class DwuConfigManager
    {
        public DwuConfigs DwuConfigs;

        public DwuConfigManager(string dwuConfigJsonFile)
        {
            using (StreamReader r = new StreamReader(dwuConfigJsonFile))
            {
                string json = r.ReadToEnd();
                DwuConfigs = JsonConvert.DeserializeObject<DwuConfigs>(json);
            }
        }

        /// <summary>
        /// Get next/up level DWU config for the given dwu config
        /// </summary>
        /// <param name="dwu">DWU config string, e.g. DWU100</param>
        /// <returns>Up level DWU config string</returns>
        public string GetUpLevelDwu(string dwu)
        {
            int i = Array.IndexOf(DwuConfigs.DwuConfigArray, dwu);
            // If it is already at max level, return as it is
            if (i == DwuConfigs.DwuConfigArray.Length - 1)
            {
                return dwu;
            }
            if (i >= 0)
            {
                return DwuConfigs.DwuConfigArray[i + 1];
            }
            throw new ArgumentException($"Unsupported DWU was given!");
        }

        /// <summary>
        /// Get prior/down level DWU config for the given dwu config
        /// </summary>
        /// <param name="dwu">DWU config string e.g. DWU100</param>
        /// <returns>Down level config string</returns>
        public string GetDownLevelDwu(string dwu)
        {
            int i = Array.IndexOf(DwuConfigs.DwuConfigArray, dwu);
            // If it is already at min level, return as it is
            if (i == 0)
            {
                return dwu;
            }
            if (i > 0)
            {
                return DwuConfigs.DwuConfigArray[i - 1];
            }
            throw new ArgumentException($"Unsupported DWU was given!");
        }

        /// <summary>
        /// Compare two DWU config strings
        /// </summary>
        /// <param name="leftDwu">Left operand for compare</param>
        /// <param name="rightDwu">Rigt operand for compare</param>
        /// <returns>0 if both are equal; -1 if left is smaller than right; 1 if left is larger than right</returns>
        public int CompareDwus(string leftDwu, string rightDwu)
        {
            int leftLevel = Array.IndexOf(DwuConfigs.DwuConfigArray, leftDwu);
            int rightLevel = Array.IndexOf(DwuConfigs.DwuConfigArray, rightDwu);

            if (leftLevel < 0 || rightLevel < 0)
                throw new ArgumentException($"Unsupported DWU was given!");

            if (leftLevel == rightLevel)
            {
                return 0;
            }
            if (leftLevel < rightLevel)
            {
                return -1;
            }
            return 1;
        }
    }

    /// <summary>
    /// Class for JSON object mapping
    /// </summary>
    public class DwuConfigs
    {
        public string DefaultDwu { get; set; }
        public string[] DwuConfigArray { get; set; }
    }
}