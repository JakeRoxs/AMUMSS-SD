	* IMPORTANT Note: 
		> Sometimes, your anti-virus may detect some component of AMUMSS and block/quarantine it.
		  Be assure it is not a virus but its behavior may be interpreted as such by some anti-virus.
		> Please make sure to create an exception in your anti-virus when this happens.
		> Also a reboot may be required as some anti-virus do not correctly register the exception when it is created.

***************************  General Information on AMUMSS ****************************
- Installation:
	* No accented characters in the path
	* Always de-compress in a new folder on any drive like X:\AMUMSS (OR in the previous folder)
	  xxxxx NEVER in any system folder (Note: the Desktop / Downloads are also system folders) xxxxx
		
		* If de-compressed in the previous folder, AMUMSS will preserve everything in user folders
		  except changes made to AMUMSS files in AMUMSS main, ModLuaLearningCollection and MODBUILDER folders
		
		* If de-compressed in a new folder, you can copy/paste these folders from the previous version of AMUMSS
		  if you would like to preserve previous work and information...
				+ 'libMBIN_Content'
				+ 'ModScript'
				+ 'ModScript\GlobalMEFTI'
				+ 'TOOLS\NMSPE_Output' (with sub-folders Diff, libMBIN_Content and PAK_Content)
				+ 'ModBackups\BuildHistory'
				+ 'TOOLS\SavedSections'
				+ 'TOOLS\UNPACKED_DECOMPILED_PAKs'
				+ any other files in AMUMSS main not updated by the unzip file

	* Please execute BUILDMOD.bat once to re-create all user folders (if they do not exist)
	  and fetch updated tools from the web.
		> Sometimes, your anti-virus may detect some component of AMUMSS and block/quarantine it.
		  Be assure it is not a virus but its behavior may be interpreted as such by some anti-virus.
		> Please make sure to create an exception in your anti-virus when this happens.
		> Also a reboot may be required as some anti-virus do not correctly register the exception when it is created.


- See 'README-AMUMSS_Script_Rules.html' for more information about AMUMSS script usage/structure

- **** ALL OPTIONS CAN NOW BE CHANGED IN 'BUILDMOD_AUTO.bat'

   ++++++ PLEASE leave this folder alone)
- 'MODBUILDER' contains all auxiliary files needed for AMUMSS operation
   ++++++ PLEASE leave this folder alone)
 
- INFO, NOTICE, WARNING, ERROR and BUG messages
	* [INFO] 
		Simply a statement of an event that has happened (likely successful)
	* [NOTICE] 
		Statement that the user should be aware of, use for things like "This is also possible"
	* [WARNING] 
		Statement that something could be wrong but will still produce a viable mod pak (it could possibly be wrong, check!)
	* [ERROR]
		Statement that something went wrong and will not produce a mod pak (check your script!)
	* [BUG]
		Statement that AMUMSS program encountered an error (mainly lua failed to execute the core program) 
		and will not produce a mod pak (Please report 'log.lua' and 'REPORT.lua' to AMUMSS maintainers!!!)
		The best place to report is on Discord:  https://discord.gg/HFjnmnwe67
			
- Things to remember:
	Last MBIN loaded always wins in NMS.  
	
	So if mod A and B both change MBIN C than the last to load (mod B here) will see its MBIN C win
	(all the values inside MBIN C of mod B are used, none from mod A).
	
	At the same time, if mod A also has MBIN D and mod B also has MBIN E then: 
	MBIN D AND MBIN E are both winners (there is no conflicting MBIN to be overwritten by mod B being loaded after mod A)

- When one or more scripts make changes to the same EXML/MBIN file:
    The order of processing is not relevant, EXCEPT A) if the 1st script ADDs sections that could be targeted by the
	2nd script (maybe targeting the wrong section) or B) the 2nd script REMOVEs sections that are required for the
	good 'operation' of the 1st script (thus making the 1st script 'effect' defective maybe)

- One of the lua scripts modifies the same value in the .pak file, which one wins?
	Easy answer:  
	
	Put the pak AND the script modifying the same MBIN in ModScript, 
	run BUILDMOD.bat and look at the values in the resulting files in TOOLS\MODDER_Helper folder 
	(both orignal and modded files are there)  
	
	Find out which values were changed by comparing the files
	
- Creating a Patch or Merging mods

			================== VERY IMPORTANT WARNING ================
			
	Using an 'older' pak (a pak that is NOT updated to the 'current' NMS MBIN file content)  
	could result in a not functional pak that could crash NMS.
	
		- Since AMUMSS will fetch the MBIN (called for by the script(s)) from the 'older' pak, 
		  if that MBIN is NOT a modded 'current' version, the resulting modded MBIN may not be
		  compatible with NMS
		
		- Note that AMUMSS cannot correct the faulty MBIN when it is an 'older' version because it cannot
		  know if the changes made in the 'older' pak to the MBIN were intentional (by the modder)
		  or due to NMS upgrading that MBIN
		  
            ================== VERY IMPORTANT WARNING ================
	
	- How to Create a Patch for existing MOD PAKs ?
			 =====  Also relevant each time you use an existing pak in a 'combined' pak  =====
		see file 'Creating a Patch for existing MOD PAKs.txt' in AMUMSS main folder

	- Merging mods, some cases here:
		A) you have 2 (or more) lua scripts for those mods, just use these in ModScript folder, run AMUMSS and you are done.
		   AMUMSS created a mod pak.
		   
		B) one mod is missing a lua script, you can still create a patch mod: see 'Creating a Patch for existing MOD PAKs.txt' for details.
		
		C) you don't have any lua script.  
			You can 'open' the mod paks using AMUMSS.
			Just put the paks (no lua script) in ModScript and AMUMSS will attempt to un-pack/de-compile them
			in their own folders under the TOOLS\UNPACKED_DECOMPILED_PAKs folder.
			Then you need to examine the changes made to the EXMLs of those mod paks
			and create a lua script that will include those changes.  Then you do A) above.
			AMUMSS does not create lua scripts by itself...

	- If you have 3 paks modifying the same MBIN file:
		Options A): Create 3 lua scripts.  Now you can easily update your mod in record time after NMS changes.

		Options B): Create 2 lua scripts for two of the paks that you use and, with the 3rd pak, create a patch
			However, the 3rd pak may become outdated if NMS changes things in the implicated MBIN.
			You will need the 3rd pak AND the patch pak (loading after the 3rd pak) in your NMS MODS folder for the patch to work
			*** see 'VERY IMPORTANT WARNING' above ***  
			
- Things Found in AMUMSS Main Folder:
	- Generated files
		* 'REPORT.lua' shows the curated information about the latest BuildMod.bat processing
    
		* 'log.lua' (or 'log.txt') is the raw output of the cmd window during the latest BuildMod.bat processing
        
- Things Found in AMUMSS CONFIG Folder:
		
		* 'CONFIG\NMS_FOLDER.txt' contains the path to the NMS game folder containing 'GAMEDATA' 
			(it is usually auto-generated by AMUMSS and does not, in most cases, need to be updated
            unless the game files are moved and AMUMSS cannot find them anymore)
		
		* 'CONFIG\DateTimeFormat.txt' used to modify DateTime formatting:
			AMUMSS default is ""%Y/%m/%d-%H:%M:%S""
			
			**** MODIFY AT YOUR OWN RISK ****: load order could be affected by your change
			You can alter this format string in the first line of the file 'DateTimeFormat.txt'
			found in AMUMSS main folder (remove the 'x' in front of the filename to activate).
			
			Remember that this format string MUST follow the same rules as the ISO C function 'strftime'.
			
			A value of "" will returns a reasonable date and time representation that depends on the host system 
			and on the current locale.
			
			Note: the DateTime format will be 'sanitized' when used in a file name!
            
- Additional resources in TOOLS Folder:
		* 'TOOLS\_MapFileMaker.exe' A drag/drop program to generate or update MapFileTrees for game .MXML files, on demand

		* 'TOOLS\MXML_NameHash_updater.bat' a drag/drop utility to set correct NameHash values in NMS SCENE .MXML files,
            output will be in TOOLS\NameHashUpdated folder.        

		* 'TOOLS\GetMXMLTree.bat' a drag/drop utility for a fast way to look at an MXML structure, ouputs in TOOLS\TREE
		
		* 'TOOLS\Log_file_cleaner.bat' cleans the contents of log.lua in the main directory
		
		* 'TOOLS\NMS_FULL_pak_list.txt' lists the files contents of each game .pak
            
		* 'TOOLS\NMS_pak_Dir.txtPretty.lua' lists the files contents of each game .pak, in a slightly different format
            
		* 'TOOLS\NMS_pak_list.txtPretty.lua' contains ALL file names of the paks in the NMS PCBANKS folder. 
            
		* 'TOOLS\RemoveTrailingSpacesNon-empty.bat' a drag/drop utility to remove trailing spaces on lines in any text based file 
            (EXML, Lua, txt, etc), output will be in TOOLS\CLEANED folder 
			
		* 'TOOLS\Test_AMUMSS_install.bat' a utility to test various basic functions of AMUMSS
            
		* 'TOOLS\Test_CURL.bat' A utility to test that Curl, the program used to download updates, is functional   
		
	- Folders usage
		* 'ModScript' is where you put:
			   A) 'one or many' .lua scripts to create one combined or many individual mods 
			or B) 'one or many' .pak files (to unpack/decompile them to the 'TOOLS\UNPACKED_DECOMPILED_PAKs' folder)
			or C) one .pak plus 'one or many' .lua scripts (to create a PATCH_MOD, a special kind of combined mod)
			or D) 'one or many' .pak files and if 'one or many' of these paks have a .lua script inside, that would allow you to build a mod from it...
			
			NOTE: The order of processing can influence the resulting mod in any of the combined cases above
			  (see AMUMSS order of processing above)
			
			* sub-folder of 'ModScript' can be used to isolate a script or group of scripts
			* 'MEFTI' folders in a sub-folder of 'ModScript' and is similar to 'ModScript\GlobalMEFTI' below
			  but only applies to the current sub-folder of 'ModScript'
			* a file named '___DONOTUSE.txt' in a first level sub-folder deactivates all its content/sub-content
			* 'ModScript/Disabled scripts and paks' sub-folder can be use to disable scripts and paks for AMUMSS use
			* 'ModScript/ModHelperScripts' sub-folder can be use to store/use helper .lua scripts
			
		* 'CreatedMODS' is where you will find the latest created MOD(s)
		* 'ModBackups\BuildHistory' is where copies of all your current and past created MODs reside
			sub-folder 'ModBackups\IncrementalBuilds' contains up to OPTION -IncrementalBuilds copies of your created MODs versions
		* 'libMBIN_Content' contains Content_libMBIN_vx.x.x.x.lua' files that reports all structures and fields in a simple format
            that can be used to compare with preceding version for name changes/additions
		* 'TOOLS\ModLuaLearningCollection' contains a collection of .lua scripts that can generally be used to learn AMUMSS syntax.  Some are outdated, 
            so not actually useable to create a working .pak for NMS.
		* 'TOOLS\Useful Utility Scripts' contains a collection of .lua scripts that can help generate useful information, see scripts for details 
		* 'ModScript\GlobalMEFTI' where you, the modder, can put ANY extra files, of any type, to be INCLUDED in the created MODs
			The additional files will be put into the paks as is.  Exactly with their folders and files, 
			compiled if .exml and packed with the normal mbin files into the final paks
		* 'TOOLS\TOOLS\TOOLS\MODDER_Helper' containing copies of the original and modified files so modders can view and compare the files during script development
		* 'TOOLS\MapFileTrees' contains MapFileTree files automaticaly created which can GREATLY help a modder find the right 
			SPECIAL_KEY_WORDS (UNIQUE or not) and PRECEDING_KEY_WORDS as well as understand the structure of an original EXML
    * 'TOOLS\ModScriptCheck' contains serialized versions of the script as AMUMSS sees it.  A postserial.lua version may also be found if 
      the script included one or more VCT func().  NOTE: the option must be turned ON in BUILDMOD_AUTO.bat (-SerializeScript Y) and BUILDMOD_AUTO.bat used
      to process the scripts.
		* 'TOOLS\UNPACKED_DECOMPILED_PAKs' is where unpacked/decompiled .pak reside in their own 'modname' folders
			along with a 'REPORT_pakname.txt' file
		* 'TOOLS\SavedSections' contains SEC_SAVE_TO files

		* 'MODBUILDER' contains all auxiliary files needed for AMUMSS operation (please leave this folder alone)
	
- ADD and REMOVE operations:
	The ADD_REMOVE scripts do include both operations if you look at all the script content. 

	In ADD_REMOVE_FORLOOP_usage-Recipes.lua, you can see the REMOVE parts AFTER the end 
		of the NMS_MOD_DEFINITION_CONTAINER (by exception) because the script programmatically 
		injects the REMOVE section in the EXML_CHANGE_TABLE.  (A bit more involved in lua stuff)

	In ADD_REMOVE_TEXT_EXAMPLE.lua, the REMOVE section is the next to last one of the EXML_CHANGE_TABLE.

	Replacing in place does not involve ADD / REMOVE if you are just changing values.

	That said, if you want to replace, it is usually a two step affair:
		Easiest way is to target the section you want to replace 
		and first ADD your new section after it.  
		Then re-target the same section and REMOVE it. 
		You are then left with only the ADDed section.

- Conflicting LUA script are ok 
	if they don't change the same exact value, as long as you process them at the same time.

	This is how it works:
		1st script that use a new MBIN file will fetch that from PCBANKS or a pak in ModScript.
		2nd script that modifies the same MBIN doesn't need to fetch it again
			and uses the one already invoked by the 1st script and so on...

	It is like if you had only one script making the different changes.
	
	Of course, if you change the same value 2 times, only the last change exist in the exml file that
	will be use to create the pak.

- About Conflicts:  
      
    Conflicts also may come from the fact that a pak is already in your MODS folder   
    AND you asked AMUMSS to also check Conflicts against the MODS folder.  
      
    Since AMUMSS cannot know if this pak is in fact from this .lua script   
    (the pak name could have been renamed by the user), it flags it as 'in conflict'.    
      
    But since you may know this is not the case, you can then safely disregard these conflicts.  

- LUA Coding Tip:
    -In a loop, it is much faster to use a table to store strings and do a table.concat()  
      than to concatenate strings.  As an example:  
  
      function UsingConcatenation() -- may take 50 sec to complete  
          local NbIteration = 200000  
          print("NbIteration = "..NbIteration)  
          local a = "MyString"  
          local b = a  
          for i=1,NbIteration do  
            b = b..a  
          end  
          print(#b)  
      end  
  
      function UsingTable()       -- takes only less than 1 sec to complete for the same result  
          local NbIteration = 200000  
          print("NbIteration = "..NbIteration)  
          local a = "MyString"  
          local T = {}  
          T[1] = a  
          for i=1,NbIteration do  
            T[#T+1] = a  
          end  
          b = table.concat(T)  
          print(#b)  
      end  
  
