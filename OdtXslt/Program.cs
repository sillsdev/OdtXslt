// ---------------------------------------------------------------------------------------------
#region // Copyright (c) 2013, SIL International. All Rights Reserved.
// <copyright from='2013' to='2013' company='SIL International'>
//		Copyright (c) 2013, SIL International. All Rights Reserved.
//
//		Distributable under the terms of either the Common Public License or the
//		GNU Lesser General Public License, as specified in the LICENSING.txt file.
// </copyright>
#endregion
//
// File: OdtXslt.cs
// Responsibility: Greg Trihus
// ---------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.Xsl;
using Mono.Options;
using ICSharpCode.SharpZipLib.Zip;


namespace OdtXslt
{
    class Program
    {
        static int _verbosity = 0;
        private static readonly XslCompiledTransform MultiPix = new XslCompiledTransform();

        static void Main(string[] args)
        {
// ReSharper disable AssignNullToNotNullAttribute
            MultiPix.Load(XmlReader.Create(Assembly.GetExecutingAssembly().GetManifestResourceStream(
                "OdtXslt.MultiPix.xsl")));
// ReSharper restore AssignNullToNotNullAttribute
            bool showHelp = false;
            bool makeBackup = true;
            var  items = new List<string>();
            var transforms = new List<string>();
            var output = new List<string>();
            var myArgs = new List<string>();

            // see: http://stackoverflow.com/questions/491595/best-way-to-parse-command-line-arguments-in-c
            var p = new OptionSet {
                { "i|item=", "the {ITEM} in the ODT (or docx).",
                   v => items.Add (v) },
                { "c|content", 
                   "Use content.xml for the item.",
                    v => items.Add( "content.xml") },
                { "s|styles", 
                   "Use styles.xml for the item.",
                    v => items.Add( "styles.xml") },
                { "t|transform=", "the {TRANSFORM} to apply to the item.\n" +
                        "Defaults to the internal transform.",
                   v => transforms.Add (v) },
                { "o|output=", "the output file for saving the result.\n" +
                        "Defaults to replacing the file in the source package.",
                   v => output.Add (v) },
                { "d|define=", "define argument:value for transformation.",
                   v => myArgs.Add (v) },
                { "v", "increase debug message verbosity",
                   v => { if (v != null) ++_verbosity; } },
                { "b|backup",  "controls making backup files", 
                   v => makeBackup = v != null },
                { "h|help",  "show this message and exit", 
                   v => showHelp = v != null },
            };

            List<string> extra;
            try
            {
                extra = p.Parse(args);
                if (extra.Count == 0)
                {
                    Console.WriteLine("Enter full file name to process");
                    extra.Add(Console.ReadLine());
                }
            }
            catch (OptionException e)
            {
                Console.Write("OdtXslt: ");
                Console.WriteLine(e.Message);
                Console.WriteLine("Try `OdtXslt --help' for more information.");
                return;
            }

            if (showHelp || extra.Count != 1)
            {
                ShowHelp(p);
                return;
            }

            var xsltArgs = new XsltArgumentList();
            CreateArgumentList(myArgs, xsltArgs);

            foreach (string  fullName in extra)
            {
                Debug("Processing: {0}", fullName);
                if (makeBackup)
                {
                    MakeBackupFile(fullName);
                }
                var odtFile = new ZipFile(fullName);
                if (transforms.Count == 0)
                    ProcessTransform(items, odtFile, xsltArgs);
                else
                {
                    foreach (string transform in transforms)
                    {
                        Debug("Transforming with: {0}", transform);
                        MultiPix.Load(XmlReader.Create(transform));
                        ProcessTransform(items, odtFile, xsltArgs);
                    }
                }
                odtFile.Close();
            }
        }

        private static void CreateArgumentList(IEnumerable<string> myArgs, XsltArgumentList xsltArgs)
        {
            foreach (string definition in myArgs)
            {
                if (definition.Contains(":"))
                {
                    var defParse = definition.Split(':');
                    xsltArgs.AddParam(defParse[0], "", defParse[1]);
                }
                else
                {
                    xsltArgs.AddParam(definition, "", true);
                }
            }
        }

        private static void MakeBackupFile(string fullName)
        {
            int n = 0;
            string bakName;
            var fullNameWOext = Path.Combine(Path.GetDirectoryName(fullName), Path.GetFileNameWithoutExtension(fullName));
            var ext = Path.GetExtension(fullName);
            do
            {
                n += 1;
                bakName = string.Format("{0}-{1}{2}", fullNameWOext, n, ext);
            } while (File.Exists(bakName));
            try
            {
                Debug("Making backup file: {0}", bakName);
                File.Copy(fullName, bakName);
            }
            catch (UnauthorizedAccessException)   // Don't make backup if the folder is not writeable
            {
            }
        }

        private static void ProcessTransform(IEnumerable<string> items, ZipFile odtFile, XsltArgumentList xsltArgs)
        {
            foreach (string item in items)
            {
                var temp = Path.GetTempFileName();
                var settings = new XmlReaderSettings {ProhibitDtd = true, XmlResolver = null};
                var namePat = new Regex(item.Replace(@"\", @"/").Replace(".", @"\.").Replace("*", ".*"), RegexOptions.IgnoreCase);
                var zipEntryEnum = odtFile.GetEnumerator();
                for (var n = 0L; n < odtFile.Count; ++n)
                {
                    zipEntryEnum.MoveNext();
                    var zipEntry = (ZipEntry)zipEntryEnum.Current;
                    var name = zipEntry.Name;
                    if (namePat.Match(name).Success)
                    {
                        Debug("Processing: {0} in {1}", name, odtFile.Name);
                        var xhtmlFile = new FileStream(temp, FileMode.Create);
                        var htmlw4 = XmlWriter.Create(xhtmlFile, MultiPix.OutputSettings);
                        var reader = new StreamReader(odtFile.GetInputStream(zipEntry.ZipFileIndex));
                        var reader4 = XmlReader.Create(reader, settings);
                        try
                        {
                            xsltArgs.RemoveParam("inputFileName", "");
                        }
                        catch (Exception)
                        {
                        }
                        finally
                        {
                            xsltArgs.AddParam("inputFileName", "", name);
                        }
                        MultiPix.Transform(reader4, xsltArgs, htmlw4, null);
                        xhtmlFile.Close();
                        var curDir = Environment.CurrentDirectory;
                        Environment.CurrentDirectory = Path.GetTempPath();
                        var entryDirectory = Path.GetDirectoryName(name);
                        if (!string.IsNullOrEmpty(entryDirectory))
                            Directory.CreateDirectory(entryDirectory);
                        const bool overwrite = true;
                        File.Copy(temp, name, overwrite);
                        File.Delete(temp);
                        odtFile.BeginUpdate();
                        odtFile.Add(name);
                        odtFile.CommitUpdate();
                        File.Delete(name);
                        if (!string.IsNullOrEmpty(entryDirectory))
                            Directory.Delete(entryDirectory);
                        Environment.CurrentDirectory = curDir;
                    }
                }
            }
        }

        static void ShowHelp(OptionSet p)
        {
            Console.WriteLine("Usage: OdtXslt [OPTIONS]+ message");
            Console.WriteLine("Apply an XSLT to the some ITEM in the ODT (or DOCx) file.");
            Console.WriteLine();
            Console.WriteLine("Options:");
            p.WriteOptionDescriptions(Console.Out);
        }

        static void Debug(string format, params object[] args)
        {
            if (_verbosity > 0)
            {
                Console.Write("# ");
                Console.WriteLine(format, args);
            }
        }
    }
}
