﻿// --------------------------------------------------------------------------------------------
// <copyright file="FileComponents.cs" from='2009' to='2014' company='SIL International'>
//      Copyright ( c ) 2009, SIL International. All Rights Reserved.   
//    
//      Distributable under the terms of either the Common Public License or the
//      GNU Lesser General Public License, as specified in the LICENSING.txt file.
// </copyright> 
// <author>Greg Trihus</author>
// <email>greg_trihus@sil.org</email>
// Last reviewed: 
// 
// <remarks>
// 
// </remarks>
// --------------------------------------------------------------------------------------------

using System;
using System.Collections;
using System.IO;
using System.Text;
using System.Xml;
using System.Collections.Generic;
using System.Diagnostics;
using System.Reflection;

namespace BuildStep
{
    public class FileComponents
    {
        #region Properties
        #region Product
        private string _product;
        public string Product
        {
            get { return _product; }
            set { _product = value; }
        }
        #endregion Product

        #region BasePath
        private string _basePath = Environment.CurrentDirectory;

        public string BasePath
        {
            get { return _basePath; }
            set { _basePath = value; }
        }
        #endregion BasePath

        #region ApplicationFileName
        private string _applicationFileName;
        public string ApplicationFileName
        {
            get { return _applicationFileName; }
            set { _applicationFileName = value; }
        }
        #endregion ApplicationFileName
        #endregion Properties

        protected readonly XmlDocument XDoc = new XmlDocument();
        private const string Wixns = "http://schemas.microsoft.com/wix/2006/wi";

        public bool Execute()
        {
            var path = _basePath;
            LoadGuids(Path.Combine(path, "FileLibrary.xml"));
            var directoryInfo = new DirectoryInfo(Path.Combine(path, "../output/Release"));
            ResetFileComponents();
            ProcessFoldersAndFiles((XmlElement)XDoc.SelectSingleNode("//*[@Id='APPLICATIONFOLDER']"), directoryInfo);
            AddFeatures();
            var writer = XmlWriter.Create(Path.Combine(_basePath,_applicationFileName), new XmlWriterSettings { Indent = true, Encoding = Encoding.UTF8 });
            XDoc.WriteTo(writer);
            writer.Close();
            SaveGuids(Path.Combine(path, "FileLibrary.xml"));
            return true;
        }

        protected void ResetFileComponents()
        {
            XDoc.RemoveAll();
            var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream("BuildStep.ApplicationTemplate.wxs");
            Debug.Assert(stream != null, "ApplicationTemplate.wxs missing from BuildTasks project resources");
            XDoc.Load(XmlReader.Create(stream));
        }

        protected readonly ArrayList CompIds = new ArrayList();

        protected void ProcessTree(XmlElement parent, string path)
        {
            var info = new DirectoryInfo(path);
            if (info.Name.Substring(0,1) == ".") return;
            var dirElem = CreateFileSystemElement("Directory", info);
            var removeComp = XDoc.CreateElement("Component", Wixns);
            var compId = "Remove" + dirElem.Attributes["Id"].Value;
            CompIds.Add(compId);
            AddAttribute("Id", compId, removeComp);
            AddAttribute("Guid", Guid.NewGuid().ToString().ToUpper(), removeComp);
            var removeElem = XDoc.CreateElement("RemoveFolder", Wixns);
            AddAttribute("Id", "RemDir" + dirElem.Attributes["Id"].Value, removeElem);
            AddAttribute("Directory", dirElem.Attributes["Id"].Value, removeElem);
            AddAttribute("On", "uninstall", removeElem);
            removeComp.AppendChild(removeElem);
            var regElem = XDoc.CreateElement("RegistryValue", Wixns);
            AddAttribute("Root", "HKCU", regElem);
            AddAttribute("Key", @"Software\SIL\" + Product, regElem);
            AddAttribute("Type", "string", regElem);
            AddAttribute("Value", "", regElem);
            AddAttribute("KeyPath", "yes", regElem);
            removeComp.AppendChild(regElem);
            dirElem.AppendChild(removeComp);
            ProcessFoldersAndFiles(dirElem, info);
            parent.AppendChild(dirElem);
        }

        private void ProcessFoldersAndFiles(XmlElement parent, DirectoryInfo info)
        {
            foreach (DirectoryInfo directoryInfo in info.GetDirectories())
            {
                ProcessTree(parent, directoryInfo.FullName);
            }
            foreach (FileInfo fileInfo in info.GetFiles())
            {
                var compElem = XDoc.CreateElement("Component", Wixns);
                var regValueElem = XDoc.CreateElement("RegistryValue", Wixns);
                AddAttribute("Root", "HKCU", regValueElem);
                AddAttribute("Key", @"Software\SIL\" + Product, regValueElem);
                AddAttribute("Name", GetSource(fileInfo), regValueElem);
                AddAttribute("Type", "string", regValueElem);
                AddAttribute("Value", "1", regValueElem);
                AddAttribute("KeyPath", "yes", regValueElem);
                compElem.AppendChild(regValueElem);
                var fileElem = CreateFileSystemElement("File", fileInfo);
                AddAttribute("Checksum", "yes", fileElem);
                AddAttribute("DiskId", "1", fileElem);
                AddAttribute("Source", GetSource(fileInfo), fileElem);
                compElem.AppendChild(fileElem);
                var compId = fileElem.Attributes.GetNamedItem("Id").Value;
                CompIds.Add(compId);
                AddAttribute("Id", compId, compElem);
                AddAttribute("Guid", GetGuid(fileInfo), compElem);
                parent.AppendChild(compElem);
            }
        }

        protected void AddFeatures()
        {
            var features = XDoc.SelectSingleNode("//*[@Id='Application']");
            Debug.Assert(features != null, "features != null");
            foreach (string compId in CompIds)
            {
                var compElem = XDoc.CreateElement("ComponentRef", Wixns);
                AddAttribute("Id", compId, compElem);
                features.AppendChild(compElem);
            }
        }

        protected readonly Dictionary<string, string> Guids = new Dictionary<string, string>();

        protected string GetGuid(FileInfo fileInfo)
        {
            const string pathbase = @"output\Release";
            var guidPathKey = GetSource(fileInfo).Substring(4 + pathbase.Length);
            if (Guids.ContainsKey(guidPathKey))
                return Guids[guidPathKey];
            var guid = Guid.NewGuid().ToString().ToUpper();
            Guids[guidPathKey] = guid;
            return guid;
        }

        protected void LoadGuids(string libraryPath)
        {
            var guidStore = new XmlDocument();
            guidStore.Load(libraryPath);
            ResetIds();
            Debug.Assert(guidStore.DocumentElement != null, "GuidStore.DocumentElement != null");
            foreach (XmlNode child in guidStore.DocumentElement.ChildNodes)
            {
                Debug.Assert(child.Attributes != null, "child.Attributes != null");
                Guids[child.Attributes.GetNamedItem("Path").Value] =
                    child.Attributes.GetNamedItem("ComponentGuid").Value;
            }
        }

        protected void SaveGuids(string libraryPath)
        {
            var guidStore = new XmlDocument();
            guidStore.LoadXml("<FileLibrary/>");
            foreach (string key in Guids.Keys)
            {
                var guidElem = guidStore.CreateElement("File");
                AddAttribute("Path", key, guidElem, guidStore);
                AddAttribute("ComponentGuid", Guids[key], guidElem, guidStore);
                Debug.Assert(guidStore.DocumentElement != null, "GuidStore.DocumentElement != null");
                guidStore.DocumentElement.AppendChild(guidElem);
            }

            var writer = XmlWriter.Create(libraryPath, new XmlWriterSettings{Indent = true, Encoding = Encoding.UTF8});
            guidStore.WriteTo(writer);
            writer.Close();
        }

        protected string GetSource(FileInfo fileInfo)
        {
            var idx = fileInfo.FullName.IndexOf(@"\output\", StringComparison.Ordinal);
            return ".." + fileInfo.FullName.Substring(idx);
        }

        private XmlElement CreateFileSystemElement(string tag, FileSystemInfo info)
        {
            var elem = XDoc.CreateElement(tag, Wixns);
            AddAttribute("Id", MakeId(info.Name), elem);
            AddAttribute("Name", info.Name, elem);
            return elem;
        }

        /// <summary>
        /// Add Attribute tag with value to element
        /// </summary>
        private static void AddAttribute(string tag, string value, XmlElement element, XmlDocument doc)
        {
            var idAttr = doc.CreateAttribute(tag);
            idAttr.Value = value;
            element.Attributes.Append(idAttr);
        }
        private void AddAttribute(string tag, string value, XmlElement element)
        {
            AddAttribute(tag, value, element, XDoc);
        }

        protected static readonly Dictionary<string,int> AllIds = new Dictionary<string, int>();
        protected string MakeId(string name)
        {
            var id = name.ToLower().ToCharArray();
            const string validChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.";
            const int notFound = -1;
            for (int iChar = 0; iChar < id.Length; iChar += 1)
                if (validChars.IndexOf(id[iChar]) == notFound)
                    id[iChar] = '_';
            var sb = new StringBuilder(id.Length);
            sb.Insert(0, id);
            string candidate = sb.ToString();
            const string validFirstChar = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_";
            if (validFirstChar.IndexOf(id[0]) == notFound)
                candidate = "_" + candidate;
            const int maxLen = 72;
            if (candidate.Length > maxLen)
                candidate = candidate.Substring(0, maxLen);
            if (AllIds.ContainsKey(candidate))
            {
                // Candidate is not unique: it needs a numerical suffix; see what next available one is:
                var currentMax = AllIds[candidate] + 1;
                AllIds[candidate] = currentMax;
                if (candidate.Length >= maxLen - 3)
                    return candidate.Substring(0, maxLen - 3) + currentMax;
                return candidate + currentMax;
            }
            // If Id is unique, register it first, before returning it:
            AllIds[candidate] = 1;
            return candidate;
        }

        protected void ResetIds()
        {
            Guids.Clear();
            AllIds.Clear();
            CompIds.Clear();
        }
    }
}
