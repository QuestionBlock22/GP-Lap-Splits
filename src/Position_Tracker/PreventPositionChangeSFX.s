# Prevent playback of the position change sound effects and the bounce animation (eOpen) if the Time Trial splits page is active.

# Inject @
# PAL   : 807f4ac4
# NTSC-U: 807ea49c
# NTSC-J: 807f4130
# NTSC-K: 807e2e84

# .set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Return
    .set return, 0x807f4b1c
.elseif (region == 'E' || region == 'e')
    # Return
    .set return, 0x807ea4f4
.elseif (region == 'J' || region == 'j')
    # Return
    .set return, 0x807f4188
.elseif (region == 'K' || region == 'k')
    # Return
    .set return, 0x807e2edc
.else
    .err
.endif

bctrl                   # Original instruction.
lwz r11, 0x38 (r30)
cmpwi r11, 0
beq end                 # Anti-freeze
lwz r0, 0x8 (r11)       # CtrlRaceRankNum->(TimeAttackSplitsPage&)->pageState
cmpwi r0, 1             # Probably not needed. Will keep as a fail-safe.
beq disableSFX
cmpwi r0, 3             # Meat and mushrooms.
bne end

disableSFX:
lis r11, return@h
ori r11, r11, return@l
mtctr r11
bctr
end: