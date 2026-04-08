# Register page ID 0x2d with the Grand Prix section. This ensures that the results screen is next in line after the splits page.

# Inject @
# PAL   : 8062c5b8
# NTSC-U: 805fb704
# NTSC-J: 8062bd04
# NTSC-K: 8061a9b0

# set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Functions
    .set Page_loadPage, 0x80622d08
.elseif (region == 'E' || region == 'e')
    # Functions
    .set Page_loadPage, 0x805f1e54
.elseif (region == 'J' || region == 'j')
    # Functions
    .set Page_loadPage, 0x80622454
.elseif (region == 'K' || region == 'k')
    # Functions
    .set Page_loadPage, 0x80611100
.else
    .err
.endif

mr r3, r31              # Original instruction
li r4, 0x2d
lis r12, Page_loadPage@h
ori r12, r12, Page_loadPage@l
mtctr r12
bctrl                   # Page::loadPage
mr r3, r31