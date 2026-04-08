# Keep the timer in its original position.
# Inject @
# PAL   : 807f8800
# NTSC-U: 807edd00
# NTSC-J: 807f7e6c
# NTSC-K: 807e6bc0

# set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Return Address
    .set return, 0x807f880c
.elseif (region == 'E' || region == 'e')
    # Return Address
    .set return, 0x807edd0c
.elseif (region == 'J' || region == 'j')
    # Return Address
    .set return, 0x807f7e78
.elseif (region == 'K' || region == 'k')
    # Return Address
    .set return, 0x807e6bcc
.else
    .err
.endif

lwz r0, 0xb70 (r4)                  # Original instruction (racedata->racesscenario->settings->gamemode)
cmpwi r0, 0
bne end
lis r11, return@h
ori r11, r11, return@l
mtctr r11
bctr                                # Exit hook and freeze the timer's exit animation if in Time Trials OR if f1 = f0
end:
# Call LayoutUIControl::solveAnimation