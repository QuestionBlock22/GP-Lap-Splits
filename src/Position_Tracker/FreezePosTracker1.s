# Set the correct coordinates for the position tracker element.

# WRITE32 @:
# PAL   : 048d3eb0 800017B4
# NTSC-U: 048cef48 800017B4
# NTSC-J: 048d3000 800017B4
# NTSC-K: 048c2348 800017B4

# Inject @:
# Global: 800017B4

# .set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Functions
    .set CtrlRaceBase_initSelf, 0x807ec6e8
    .set CtrlRaceTime_getPage, 0x807f8274
    .set Page_getPageId, 0x807f826c
    # Data
    .set frameNumber, 0x808b5f40
.elseif (region == 'E' || region == 'e')
    # Functions
    .set CtrlRaceBase_initSelf, 0x807e2e3c
    .set CtrlRaceTime_getPage, 0x807ed774
    .set Page_getPageId, 0x807ed76c
    # Data
    .set frameNumber, 0x808bb868
.elseif (region == 'J' || region == 'j')
    # Functions
    .set CtrlRaceBase_initSelf, 0x807ebd54
    .set CtrlRaceTime_getPage, 0x807f78e0
    .set Page_getPageId, 0x807f78d8
    # Data
    .set frameNumber, 0x808b6de0
.elseif (region == 'K' || region == 'k')
    # Functions
    .set CtrlRaceBase_initSelf, 0x807daaa8
    .set CtrlRaceTime_getPage, 0x807e6634
    .set Page_getPageId, 0x807e662c
    # Data
    .set frameNumber, 0x808a7ae0
.else
    .err
.endif

.set PAGE_TIME_ATTACK_SPLITS, 0x2d

.macro stackPush
    stwu sp, -0x10 (sp)
    mflr r0
    stw r0, 0x14 (sp)
    stmw r30, 0x8 (sp)
.endm

.macro popStack
    lmw r30, 0x8 (sp)
    lwz r0, 0x14 (sp)
    mtlr r0
    addi sp, sp, 0x10
    blr                                 # Don't go back to the EVA, please.
.endm

# void CtrlRaceRankRank::initSelf

# Initialize control coordinates.
stackPush
lis r12, CtrlRaceBase_initSelf@h
ori r12, r12, CtrlRaceBase_initSelf@l
mtctr r12
bctrl                                   # CtrlRaceBase::initSelf

# Get the current page ID and end if not the Time Trial splits page.
mr r3, r31
lis r11, CtrlRaceTime_getPage@h
ori r11, r11, CtrlRaceTime_getPage@l
mtctr r11
bctrl                                   # CtrlRaceTime::getPage (Says CtrlRaceTime, but technically can be used for any control.)
lis r12, Page_getPageId@h
ori r12, r12, Page_getPageId@l
mtctr r12
bctrl                                   # Page::getPageId
cmpwi r3, PAGE_TIME_ATTACK_SPLITS
bne end
lwz r11, 0 (r31)
mr r3, r31
lis r4, frameNumber@h
lwz r11, 0x40 (r11)
lfs f1, -frameNumber@l (r4)
mtctr r11
bctrl                                   # CtrlRaceBase::animate (virtual function)

end:
popStack