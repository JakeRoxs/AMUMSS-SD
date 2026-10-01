using libMBIN;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Xml.Linq;

namespace ArrayInfo
{
    class Program
   {
        // set path to dll/code to discover
        // so that both Debug and Release use the same path
        static String libMBINPath = Directory.GetCurrentDirectory() + "\\" + "libMBIN.dll";
        private static ConcurrentDictionary<Type,int> AlignmentMap = new ConcurrentDictionary<Type,int>();

         public static int AlignOf(Type type) {
            int alignment;

            if (AlignmentMap.TryGetValue(type, out alignment)) {
                return alignment;
            }

            switch (type.Name) {
                case "Boolean":
                case "Byte":
                case "SByte":
                case "String":
                    alignment = 0x1;
                    break;

                case "Int16":
                case "UInt16":
                    alignment = 0x2;
                    break;

                case "Single":
                case "Int32":
                case "UInt32":
                    alignment = 0x4;
                    break;

                case "Int64":
                case "UInt64":
                case "List`1":
                case "NMSTemplate":
                case "VariableSizeString":
                    // TODO: See whether or not `max(0x8, AlignOf(<list subtype>))` is acctually the right value...
                    alignment = 0x8;
                    break;

                default:
                    if (type.IsArray) {
                        alignment = AlignOf(type.GetElementType());
                        break;
                    }

                    if (type.IsEnum) {
                        Type enumType = type.GetEnumUnderlyingType();
                        if ( enumType.Name == "UInt32") {
                            alignment = 0x4;
                        } else if (enumType.Name == "UInt16") {
                            alignment = 0x2;
                        } else {
                            alignment = 0x1;
                        }
                        break;
                    }

                    NMSAttribute settings = type.GetCustomAttribute<NMSAttribute>();
                    if (settings != null && settings.Alignment > 0) {
                        alignment = settings.Alignment;
                        break;
                    }

                    if (type.BaseType == typeof(NMSTemplate)) {
                        alignment = 1;

                        foreach (FieldInfo field in type.GetFields()) {
                            int align = AlignOf(field.FieldType);
                            if (align > alignment) {
                                alignment = align;
                                if (alignment >= 0x10) break;
                            }
                        }

                        break;
                    }

                    throw new UnknownTypeException( type );
            }

            AlignmentMap[type] = alignment;
            return alignment;
        }

       public static int SizeOf(Type type) {
            int size = 0;

            switch (type.Name)
            {
                case "Boolean":
                case "Byte":
                case "SByte":
                case "String":
                    size = 0x1;
                    break;

                case "Int16":
                case "UInt16":
                    size = 0x2;
                    break;

                case "Single":
                case "Int32":
                case "UInt32":
                    size = 0x4;
                    break;

                case "Int64":
                case "UInt64":
                    size = 0x8;
                    break;

                case "VariableSizeString":
                case "OptionalVariableSizeString":
                case "List`1":
                case "NMSTemplate":
                    size = 0x10;
                    break;

                default:
                    if (type.IsEnum)
                    {
                        //size = SizeOf(Enum.GetUnderlyingType(type));
                        size = 0x1;
                        break;
                    }

                    NMSAttribute settings = type.GetCustomAttribute<NMSAttribute>();
                    if (settings != null && settings.Size > 0) {
                        size = settings.Size;
                        break;
                    }

                    //// For a class which inherits from the NMSTemplate, iterate over
                    //// the fields and get the total size by adding up the sizes of the
                    //// fields.
                    //int max_alignment = 1;
                    //int alignment = 1;
                    //foreach (FieldInfo field in type.GetFields()) {
                    //    alignment = AlignOf(field.FieldType);
                    //    // If the current size doesn't match the alignment of the current field,
                    //    // then align it.
                    //    if (size % alignment != 0) {
                    //        size += (alignment - (size % alignment));
                    //    }
                    //    size += SizeOf(field);
                    //    // Update the max alignment.
                    //    if (alignment > max_alignment) {
                    //        max_alignment = alignment;
                    //    }
                    //}
                    //// Finally, ensure that the total size is a multiple of the max alignment.
                    //if (size % max_alignment != 0) {
                    //    size += (max_alignment - (size % max_alignment));
                    //}
                    //// If the size is still 0 after this then it means that we got a class derived
                    //// from NMSTemplate which has no fields. We still give this a nominal size of 1.
                    //if (size == 0) {
                    //    size = 1;
                    //}
                    break;
            }

            if (size != 0) { return size; }
            // If we have got here then we have got a type which we cannot determine the size of. Raise an error.
            throw new ArgumentException($"{type.Name} has an unknown size.");
        }

        static void ParseClasses(List<Type> classes, StringBuilder data) {
            foreach (var t in classes) {
                string name = t.Name;
                var fields = t.GetFields().OrderBy(field => field.MetadataToken);
                foreach (var field in fields) {
                    string fieldName = field.Name;
                    var fieldType = field.FieldType;
                    if (fieldType.IsArray) {
                        int? strSize = field.GetCustomAttribute<NMSAttribute>()?.Size;
                        data.AppendLine($"{name}.{fieldName} ARRAY {strSize}");
                        //} else if (fieldType.IsGenericType && fieldType.GetGenericTypeDefinition() == typeof(List<>)) {
                        //    data.AppendLine($"{name}.{fieldName} LIST");
                    //} else if (fieldType.Name == "String" && !fieldType.IsEnum) {
                    //    // The length of a string is an attribute.
                    //    int? strSize = field.GetCustomAttribute<NMSAttribute>()?.Size ?? 0;
                    //    data.AppendLine($"{name}.{fieldName} STRING {strSize}");
                    //} else if (!fieldType.IsEnum ) {
                    //    int? strSize = SizeOf(field.FieldType);
                    //    data.AppendLine($"{name}.{fieldName} OTHER {strSize}");
                    }
                }
            }
        }

        static int Main(string[] args)
        {
            if (!File.Exists(libMBINPath)) {
                Console.WriteLine($"Error: Could not find libMBIN.dll at {libMBINPath}");
                return 1;
            }

            //var asm = Assembly.Load($"libMBIN");
            //var asm = Assembly.LoadFile(libMBINPath);
            var asm = Assembly.LoadFrom(libMBINPath);

            // Load all the classes
            var tk_classes = asm.GetTypes().Where(p =>
                 p.Namespace == "libMBIN.NMS.Toolkit" &&
                 p.IsEnum == false
            ).OrderBy(p => p.Name).ToList();
            var gc_classes = asm.GetTypes().Where(p =>
                 p.Namespace == "libMBIN.NMS.GameComponents" &&
                 p.IsEnum == false
            ).OrderBy(p => p.Name).ToList();
            var globals_classes = asm.GetTypes().Where(p =>
                 p.Namespace == "libMBIN.NMS.Globals" &&
                 p.IsEnum == false
            ).OrderBy(p => p.Name).ToList();

            StringBuilder data = new StringBuilder();

            string assemblyVersion = asm.GetName().Version.ToString(); 
            data.AppendLine($"libMBIN, version={assemblyVersion}");
            data.AppendLine("");
            
            ParseClasses(tk_classes, data);
            ParseClasses(gc_classes, data);
            ParseClasses(globals_classes, data);
            File.WriteAllText("array_data.txt", data.ToString());

            return 0;
        }
    }
}
