How do MBINs and EXMLs coexist in GAMEDATA\MODS sub-folders:

- MBINs always replace entire files and the last mod to load a particular MBIN wins.
    If two mods replace the same MBIN, they won't work together.  Only the last MBIN to load will be active.

- EXMLs replace individual lines in a MBIN file. 
    If two mods edit the same MBIN by using an EXML,
    they will work fine provided they aren't editing the same value lines. 

If one mod has a MBIN and another (or others) has an EXML of the same MBIN,
   the EXML values will replace the MBIN values, so both will work
   (assuming the EXML values are not undoing the changes from the MBIN mod).

It follows that EXMLs will only need updating very rarely.

Some MBINs cannot be converted to EXML (a decision made by HG).
Thus, some mods are made of MBINS (and possibly some EXMLs).

AMUMSS can help create both modded MBINs and EXMLs when a script is available.

Scripts are instructions to AMUMSS to make the mod, NOT a mod.

