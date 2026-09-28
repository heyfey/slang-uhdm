# r11u199: the law -> switch map of the two landings under verification (pass 192 = the eight r11u192 laws + v11u192's
# refinement, b6344400; pass 193 = the seven r11u193 laws + v11u193's three refinements, b8719ea9), the r11u194
# refinements on top (4a65840e), and the partners of the composition census (passes 187, 188, r11u190's refinements).
# (§ pkgTfBodyCmViewClone192 is NOT a law of this pass 192: it is the 2026-09-07 block-3 "UVM pass 192" (287bbc94c),
# switchless; no law here names it.)
SW = {
 # landing 192 (b6344400)
 'psBoundPaOwnerName192': ['R11U192_PSOWNER_OFF'],
 'genForReplCountOwner192': ['R11U192_GFREPL_OFF'],
 'procPsBoundOwner192': ['R11U192_PROCPS_OFF'],
 'tfPsBoundOwner192': ['R11U192_TFPS_OFF'],
 'ndaPsBoundOwner192': ['R11U192_NDAPS_OFF'],
 'caPsSelFullVerbatim192': ['R11U192_PSVERB_OFF'],
 'pkgQualBoundSpanQualifier192': ['R11U192_QBSPAN_OFF'],
 'pkgPatReadTsBindsTopTypedef192': ['R11U192_PATTD_OFF'],
 'genForWholeLhsNestedKeep192v': ['R11V192_WHOLELHS_OFF'],
 # landing 193 (b8719ea9)
 'castOperandLeafElab193': ['R11U193_CASTLEAF_OFF'],
 'connCastTsNamedByPort193': ['R11U193_CASTTSNAME_OFF'],
 'connSysCallArgDefNet193': ['R11U193_SYSARGDEF_OFF'],
 'caTernFillArmKept193': ['R11U193_TERNFILL_OFF'],
 'caUnsizedRhsClonePerInst193': ['R11U193_UNSIZEDCLONE_OFF'],
 'nestedDefChainName193': ['R11U193_NESTNAME_OFF'],
 'tfArgOutsideCopyOrder193': ['R11U193_COPYORDER_OFF'],
 'nestChainKeepsPkgQual193v': ['R11V193_NESTPKGQ_OFF'],
 'nestChainSelects193v': ['R11V193_NESTSEL_OFF'],
 'ucCloneUnnamesRanges193v': ['R11V193_UCRANGE_OFF'],
 # r11u194 refinements (4a65840e)
 'tpCaPortNetIsVar194v': ['R11V194_TPCAPORT_OFF'],
 'incDecSelCallArgRead194v': ['R11V194_IDCALLARG_OFF'],
}
# A refinement is also scored against its parent's switch (pristine for that site).  The 192v refinement only
# restricts two branches (PSOWNER's for-generate branch and GFREPL), so its parent is both; PSOWNER is named.
PARENT = {'genForWholeLhsNestedKeep192v': 'psBoundPaOwnerName192',
          'nestChainKeepsPkgQual193v': 'nestedDefChainName193',
          'nestChainSelects193v': 'nestedDefChainName193',
          'ucCloneUnnamesRanges193v': 'caUnsizedRhsClonePerInst193'}
LANDING = {192: ['R11U192_OFF', 'R11V192_OFF'],
           193: ['R11U193_OFF', 'R11V193_OFF'],
           194: ['R11V194_OFF'],
           187: ['R11U187_OFF'],
           188: ['R11U188_OFF', 'R11V188_OFF'],
           190: ['R11V190_OFF']}
ALLOFF = LANDING[192] + LANDING[193]
OTHERS = ['R11U187_OFF', 'R11U188_OFF', 'R11V188_OFF', 'R11V190_OFF', 'R11V194_OFF']
WIDE = ALLOFF + OTHERS
def landing_of(law):
    for n in (192, 193, 194, 187, 188, 190):
        if law.endswith(str(n)) or law.endswith(f'{n}v'): return n
    return None
