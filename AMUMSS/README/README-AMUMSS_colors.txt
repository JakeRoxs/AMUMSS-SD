README-AMUMSS_colors

AMUMSS allows you to 'customize' many of the colors used throughout the code in cmd/terminal window.

The file 'CONFIG\AMUMSS_colors.cfg' is the 'standard file' used by BUILDMOD.bat and BUILDMOD_AUTO.bat.

NOTE: AMUMSS 'updates' can/will change this file from time to time.
      If you want to create a new 'color scheme', you can use CONFIG\AMUMSS_colors.cfg as a template
      and create a new file in CONFIG folder, named as you want but using the extension '.cfg'

There are two LUA tables in AMUMSS_colors.cfg:

  - Table "Colors":
      Defines the 'names' you give to colors and their RGB values
      
      'names' must conform to LUA variables name syntax:
        ==> Names in Lua can be any string of letters, digits, and underscores, 
            not beginning with a digit and not being a reserved word)
      
      You can define 'names' as many as you want
      The 'names' are used on the right side of table "UsedColors" (see below)

  - Table 'UsedColors':
      Defines how the 'named colors' above are used by the left side AMUMSS variables.
      
      ==> The 'left side variable' names are 'fixed' and 'cannot be changed',
          otherwise AMUMSS will not be able to use them.
      
      The right side color combinations are of the form: "foreground*background".
      You are free to re-define the "foreground" and/or "background" colors to use.
      Notice the '*' separating the "foreground" and "background" and NO spaces.
      "foreground" and "background" are the 'names' you gave to RBG colors in table "Colors".

