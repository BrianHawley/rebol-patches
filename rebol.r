This is an example of how you would apply the patches in rebol.r.
The version check is in case you put R2 and R3 in the same folder.

REBOL [Title: "User Settings" Type: module]

if 2.100.0 < system/version [import/no-user %patches.r3]
