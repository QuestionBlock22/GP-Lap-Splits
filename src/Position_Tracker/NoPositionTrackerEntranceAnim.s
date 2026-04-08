# Disable the position tracker entrance animation on the Time Trials splits page.

# Inject @
# PAL   : 807f4a20
# NTSC-U: 807ea3f8
# NTSC-J: 807f408c
# NTSC-K: 807e2de0

# .set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Functions
    .set CtrlRaceTime_getPage, 0x807f8274
    .set Page_getPageId, 0x807f826c
    # Return Address
    .set return, 0x807f4a30
.elseif (region == 'E' || region == 'e')
    # Functions
    .set CtrlRaceTime_getPage, 0x807ed774
    .set Page_getPageId, 0x807ed76c
    # Return
    .set return, 0x807ea408
.elseif (region == 'J' || region == 'j')
    # Functions
    .set CtrlRaceTime_getPage, 0x807f78e0
    .set Page_getPageId, 0x807f78d8
    # Return
    .set return, 0x807f409c
.elseif (region == 'K' || region == 'k')
    # Functions
    .set CtrlRaceTime_getPage, 0x807e6634
    .set Page_getPageId, 0x807e662c
    # Return
    .set return, 0x807e2df0
.else
    .err
.endif

lis r11, CtrlRaceTime_getPage@h
ori r11, r11, CtrlRaceTime_getPage@l
mtctr r11
bctrl                                   # CtrlRaceTime::getPage (Says CtrlRaceTime, but technically can be used for any control.)
lis r11, Page_getPageId@h
ori r11, r11, Page_getPageId@l
mtctr r11
bctrl                                   # Page::getPageId
cmpwi r3, 0x2d
beq end

prcessInAnimation:
mr r3, r30
lwz r12, 0 (r3)
lwz r12, 0x3c (r12)
mtctr r12
bctrl                                   # CtrlRaceBase::processInAnimation (Virtual function/Original instruction set)

end:
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr