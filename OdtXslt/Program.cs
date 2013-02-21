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
            var widths = new List<string>();

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
                { "w|width=", "the {WIDTH} of the picture boxes.",
                   v => widths.Add (v) },
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

            // Create argument list
            XsltArgumentList xsltArgs = new XsltArgumentList();
            //foreach (string paramName in m_xslParams.Keys)
            //    args.AddParam(paramName, "", m_xslParams[paramName]);
            if (widths.Count > 0)
                xsltArgs.AddParam("width", "", widths[0]);

            string fullName = extra[0];
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
                    Debug("Processing: {0}", transform);
                    MultiPix.Load(XmlReader.Create(transform));
                    ProcessTransform(items, odtFile, xsltArgs);
                }
            }
            odtFile.Close();
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
                File.Copy(fullName, bakName);
                Debug("Making backup file: {0}", bakName);
            }
            catch (UnauthorizedAccessException)   // Don't make backup if the folder is not writeable
            {
            }
        }

        private static void ProcessTransform(IEnumerable<string> items, ZipFile odtFile, XsltArgumentList xsltArgs)
        {
            foreach (string item in items)
            {
                Debug("Processing: {0} in {1}", item, odtFile.Name);
                var temp = Path.GetTempFileName();
                var xhtmlFile = new FileStream(temp, FileMode.Create);
                var htmlw4 = XmlWriter.Create(xhtmlFile, MultiPix.OutputSettings);
                var settings = new XmlReaderSettings {DtdProcessing = DtdProcessing.Ignore};
                var reader = new StreamReader(odtFile.GetInputStream(odtFile.GetEntry(item).ZipFileIndex));
                var reader4 = XmlReader.Create(reader, settings);
                MultiPix.Transform(reader4, xsltArgs, htmlw4, null);
                xhtmlFile.Close();
                var curDir = Environment.CurrentDirectory;
                Environment.CurrentDirectory = Path.GetTempPath();
                const bool overwrite = true;
                File.Copy(temp, item, overwrite);
                File.Delete(temp);
                odtFile.BeginUpdate();
                odtFile.Add(item);
                odtFile.CommitUpdate();
                File.Delete(item);
                Environment.CurrentDirectory = curDir;
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
