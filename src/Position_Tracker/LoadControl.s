# Load the position tracker element on the Time Trials splits page.

# Inject @
# PAL   : 80855abc
# NTSC-U: 8083402c
# NTSC-J: 80855128
# NTSC-K: 80843e7c

# .set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Racedata
    .set raceDataBase, 0x809c28d8 # Resolves to 809bd728 (Racedata::spInstance)
    # Functions
    .set new, 0x80229dcc
    .set UIControl_constructControl, 0x8063d798
    .set Page_insertInPage, 0x8060246c
    .set CtrlRaceRankNum_load, 0x807f4bb4
    # Virtual Tables
    .set CtrlRaceRankNum_vtable, 0x808d3e98
.elseif (region == 'E' || region == 'e')
    # Racedata
    .set raceDataBase, 0x809c7098
    # Functions
    .set new, 0x80229a48
    .set UIControl_constructControl, 0x8060c378
    .set Page_insertInPage, 0x805ddb8c
    .set CtrlRaceRankNum_load, 0x807ea58c
    # Virtual Tables
    .set CtrlRaceRankNum_vtable, 0x808cef30
.elseif (region == 'J' || region == 'j')
    # Racedata
    .set raceDataBase, 0x809c3878
    # Functions
    .set new, 0x80229cec
    .set UIControl_constructControl, 0x8063ce04
    .set Page_insertInPage, 0x80601be0
    .set CtrlRaceRankNum_load, 0x807f4220
    # Virtual Tables
    .set CtrlRaceRankNum_vtable, 0x808d2fe8
.elseif (region == 'K' || region == 'k')
    # Racedata
    .set raceDataBase, 0x809b4298
    # Functions
    .set new, 0x8022a140
    .set UIControl_constructControl, 0x8062bab0
    .set Page_insertInPage, 0x805f088c
    .set CtrlRaceRankNum_load, 0x807e2f74
    # Virtual Tables
    .set CtrlRaceRankNum_vtable, 0x808c2330
.else
    .err
.endif

# Don't run if not in Grand Prix.
lis r12, raceDataBase@h
lwz r12, -raceDataBase@l (r12)
lwz r0, 0xb70 (r12)                         # racedata -> raceScenario -> settings -> gameMode
cmpwi r0, 0
bne end
li r3, 0x1a4
lis r12, new@h
ori r12, r12, new@l
mtctr r12
bctrl                                       # new (malloc)

# Store CtrlRaceRankNum::vtable to r27 at an offset of 0xa.
lis r8, CtrlRaceRankNum_vtable@h
cmpwi r3, 0
ori r8, r8, CtrlRaceRankNum_vtable@l
mr r11, r3
beq insertControl
lis r12, UIControl_constructControl@h
ori r12, r12, UIControl_constructControl@l
mtctr r12
bctrl                                       # UIControl::constructControl
stw r8, 0x0 (r11)

insertControl:
rlwinm r4, r28, 0x0, 0x18, 0x1f
mr r3, r27                                  # TimeAttackSplits::vtable
addi r4, r4, 0x2
stw r27, 0x38 (r11)                         # Save the Time Trials splits page address to our CtrlRaceRankNum.
mr r5, r11
li r6, 0
lis r12, Page_insertInPage@h
ori r12, r12, Page_insertInPage@l
mtctr r12
bctrl                                       # Page::insertInPage
bl callFunc

CtrlRaceRankNum_1_0:
    # We only support single player, anyway.
    .asciz "CtrlRaceRankNum_1_0"
    .align 2

callFunc:
mflr r4
rlwinm r5, r17, 0x0, 0x18, 0x1f             # u8 hudSlotId*
lis r12, CtrlRaceRankNum_load@h
ori r12, r12, CtrlRaceRankNum_load@l
mtctr r12
bctrl                                       # CtrlRaceRankNum::load

end:
addi r3, sp, 0x28