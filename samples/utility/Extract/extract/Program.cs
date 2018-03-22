using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace ExtractApp
{
    class Extract
    {
        const string helpstr = "Extract Utility - Copyright © 2018 Mitch van Huuksloot, Microsoft Corporation\n" +
                                "Console utility that extracts one or more lines from a text file. Lines can end with CR, LF or CR+LF.\n\n" +
                                "Command: extract <path><file name> <start line #> <# lines to display>\n\n" +
                                "Path is optional, current directory will be used.\n" +
                                "File name and start line # are mandatory\n" +
                                "If not specified, the number of lines extracted defaults to 10\n\n" +
                                "Example: extract bigtextfile.txt 3141592654 25";

        static void Main(string[] args)
        {
            string path = "", line;
            long linenum = 1, target = 0;
            int outlines = 10;
            bool found = false;

            if (args.Length < 2 || args[0].StartsWith("?") || args[0].Contains("?") || args.Length > 3)
            {
                Console.WriteLine(helpstr);
                return;
            }
            if (args.Length > 2)
            {
                try
                {
                    outlines = Convert.ToInt32(args[2]);
                    if (outlines <= 0) outlines = 10;
                }
                catch (Exception e)
                {
                    Console.WriteLine("Exception on conversion of output lines from text to integer: " + e.Message);
                    outlines = 10;
                }
            }
            path = args[0];
            try
            {
                target = Convert.ToInt64(args[1]);
            }
            catch (Exception e)
            {
                Console.WriteLine("Exception on conversion of start line from text to integer: " + e.Message);
                return;
            }

            if (!File.Exists(path))
            {
                Console.WriteLine("File specified was not found: " + path);
                return;
            }
            if (target <= 0)
            {
                Console.WriteLine("A non zero, positive start line must be specified");
                return;
            }
            using (StreamReader sr = new StreamReader(path))
            {
                while (sr.Peek() >= 0)
                {
                    try
                    {
                        line = sr.ReadLine();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine("Exception reading line from file: " + e.Message);
                        return;
                    }
                    if (linenum == target || found)
                    {
                        Console.WriteLine(linenum.ToString() + ": " + line);
                        found = true;
                        if (--outlines == 0) break;
                    }
                    linenum++;
                }
            }
            if (!found) Console.WriteLine("The file only has " + (linenum - 1).ToString() + " lines");
#if DEBUG
            Console.ReadKey();
#endif
        }
    }
}
