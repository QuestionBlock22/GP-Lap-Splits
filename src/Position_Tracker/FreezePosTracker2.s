# Freeze the position tracker's exit animation.

# Replace virtual function.
# WRITE32 @
# PAL   : 048d3eb8 800017B0
# NTSC-U: 048cef50 800017B0
# NTSC-J: 048d3008 800017B0
# NTSC-K: 048c2350 800017B0

# Inject @
# Global: 800017B0

.if (region == 'P' || region == 'p')
    # Racedata
    .set raceDataBase, 0x809c28d8 # Resolves to 809bd728 (Racedata::spInstance)
    # Functions
    .set UIControl_solveAnimation, 0x8063d194
    # Data
    .set frameNumber, 0x808b5f40
.elseif (region == 'E' || region == 'e')
    # Racedata
    .set raceDataBase, 0x809c7098
    # Functions
    .set UIControl_solveAnimation, 0x8060bd74
    # Data
    .set frameNumber, 0x808bb868
.elseif (region == 'J' || region == 'j')
    # Racedata
    .set raceDataBase, 0x809c3878
    # Functions
    .set UIControl_solveAnimation, 0x8063c800
    # Data
    .set frameNumber, 0x808b6de0
.elseif (region == 'K' || region == 'k')
    # Racedata
    .set raceDataBase, 0x809b4298
    # Functions
    .set UIControl_solveAnimation, 0x8062b4ac
    # Data
    .set frameNumber, 0x808a7ae0
.else
    .err
.endif

# void CtrlRaceRankNum::solveAnimation

# Check the page state of the Time Trials splits page.
lwz r12, 0x38 (r3)
cmpwi r12, 0                            # Anti-freeze
beq checkFloatsGPHUD
lwz r0, 0x8 (r12)                       # CtrlRaceRankNum::vtable->(&TimeAttackSplitsPage::vtable)->pageState
cmpwi r0, 1                             # pageState = Inactive
beq checkFloatsTASplits
cmpwi r0, 3                             # pageState = Activated
beq checkFloatsTASplits
cmpwi r0, 5                             # pageState = Exiting
beq solveAnimation

# Check if the current game mode is Grand Prix.
lis r11, raceDataBase@h
lwz r11, -raceDataBase@l (r11)
lwz r0, 0xB70 (r11)                     # racedata->racesScenario->settings->gameMode
cmpwi r0, 0
bne solveAnimation

# Check if f1 is less than f0 or f1 is greater than f0, depending on the current page (GPHUDPage or TASplits page).
checkFloatsGPHUD:
lis r12, frameNumber@h
lfs f0, -frameNumber@l (r12)
fcmpo cr0, f0, f1
cror 4*cr0+eq, 4*cr0+lt, 4*cr0+eq
bne solveAnimation
fmr f1, f0
b solveAnimation

checkFloatsTASplits:
lis r12, frameNumber@h
lfs f0, -frameNumber@l (r12)
fcmpo cr0, f0, f1
cror 4*cr0+eq, 4*cr0+gt, 4*cr0+eq
bne solveAnimation
fmr f1, f0

solveAnimation:
lis r11, UIControl_solveAnimation@h
ori r11, r11, UIControl_solveAnimation@l
mtctr r11
bctr                                    # UIControl::solveAnimation