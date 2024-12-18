"Hello World!"
"\nHello\x09World!\x0A"
"Æ£±æ"              //\u00C6\u00A3\u00B1\u00E6
"\'" "'"            // Either of these are fine
"\\\"\'\x64"""      //Testing escapes and adjacent strings
"\xGG"
abc                 // These following should not be picked up
1
2
3
