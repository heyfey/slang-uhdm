# r11u190: the law -> switch map of the two landings under verification (pass 180 = ten r11u180 laws + v11u180's three
# refinements, a3a62624; pass 181 = fifteen r11u181 laws + r11v181's four refinements, 1eeff71d), and of the landings the
# composition census also switches (pass 184 on top of 181, 44393367; the verification r11u185, 2b97649e).
SW = {
 # landing 180 (a3a62624)
 'enumImportParentLastWriter180': ['R11U180_ENUMIMP_OFF'],
 'enumImpHdrBranch180': ['R11U180_ENUMIMPHDR_OFF'],           # the header-import branch of the law above
 'classTpDefaultTsAtUse180': ['R11U180_TPUSE_OFF'],
 'classTpFormalMovesTs180': ['R11U180_TPFORMAL_OFF'],
 'classTpChainRootShares180': ['R11U180_TPCHAIN_OFF'],
 'classTpQualDefaultSpan180': ['R11U180_TPQUAL_OFF'],
 'modAggTfArgCloneFollows180': ['R11U180_MODAGGCLONE_OFF'],
 'pkgAggTfArgCloneFollows180': ['R11U180_PKGAGGCLONE_OFF'],
 'ifaceWildcardTdNameOrder180': ['R11U180_IFACETDORDER_OFF'],
 'splitPortIntRedeclLogicTs180': ['R11U180_PORTINTREDECL_OFF'],
 'tfArgAggSwitchSplit180': ['R11U180_AGGSWITCH_OFF'],
 'modAggCloneOwnDefOnly180v': ['R11V180_MODAGGDEF_OFF'],
 'modAggCloneTakesFile180v': ['R11V180_MODAGGFILE_OFF'],
 'enumImpDefOwner180v': ['R11V180_ENUMDEF_OFF'],
 # landing 181 (1eeff71d)
 'rootPathFullNameByChain181': ['R11U181_ROOTFN_OFF'],
 'rootPathElemOwnName181': ['R11U181_ROOTELEM_OFF'],
 'rootNetPathOwnNames181': ['R11U181_ROOTNET_OFF'],
 'bitSelParenIdxSpan181': ['R11U181_PARENIDX_OFF'],
 'incDecBitSelWholeSpan181': ['R11U181_INCDECBS_OFF'],
 'invalidStmtAnchorSyntax181': ['R11U181_INVSTMT_OFF'],
 'bareDecUnderscoreDropped181': ['R11U181_DECUS_OFF'],
 'doWhileSyntaxFromCond181': ['R11U181_DWSYN_OFF'],
 'doWhileMacroCondEnd181': ['R11U181_DWMACRO_OFF'],
 'incDecMixedPathIsLvalue181': ['R11U181_INCDECMIX_OFF'],
 'classMethodLvIsProcess181': ['R11U181_LVCLASS_OFF'],
 'lvSelIdxChainName181': ['R11U181_LVCHAIN_OFF'],
 'procLvIdxCallWholeSpan181': ['R11U181_LVCALL_OFF'],
 'newLhsBitSelAtIndex181': ['R11U181_NEWLHS_OFF'],
 'lvIdxMixedPathIsRead181': ['R11U181_LVIDXREAD_OFF'],
 'lvIdxReadNestedKeepsLvalue181v': ['R11V181_NESTRD_OFF'],
 'lvIdxReadCallNameSpan181v': ['R11V181_RDCALL_OFF'],
 'procLvPartSelBoundCallName181v': ['R11V181_LVCALLPS_OFF'],
 'bigDecUnderscoreDropped181v': ['R11V181_DECBIG_OFF'],
 # cross-ground partners (pass 184)
 'incDecMemberSelIsLvalue184': ['R11U184_INCDECSEL_OFF'],
 'incDecSelTopRestore184v': ['R11V184_IDTOP_OFF'],
 'lvIdxMemberSelIsRead184': ['R11U184_LVIDXSEL_OFF'],
 'rootLvalueSpanAtRoot184': ['R11U184_ROOTLV_OFF'],
 'hpIdxCallNameSpan184': ['R11U184_HPIDXCALL_OFF'],
 'memberSelParenIdxSpan184': ['R11U184_MEMPAREN_OFF'],
}
PARENT = {'enumImpHdrBranch180': 'enumImportParentLastWriter180',
          'enumImpDefOwner180v': 'enumImportParentLastWriter180',
          'modAggCloneOwnDefOnly180v': 'modAggTfArgCloneFollows180',
          'modAggCloneTakesFile180v': 'modAggTfArgCloneFollows180',
          'lvIdxReadNestedKeepsLvalue181v': 'lvIdxMixedPathIsRead181',
          'lvIdxReadCallNameSpan181v': 'lvIdxMixedPathIsRead181',
          'procLvPartSelBoundCallName181v': 'procLvIdxCallWholeSpan181',
          'bigDecUnderscoreDropped181v': 'bareDecUnderscoreDropped181',
          'incDecSelTopRestore184v': 'incDecMemberSelIsLvalue184'}
LANDING = {180: ['R11U180_OFF', 'R11V180_OFF'],
           181: ['R11U181_OFF', 'R11V181_OFF'],
           184: ['R11U184_OFF', 'R11V184_OFF']}
ALLOFF = ['R11U180_OFF', 'R11V180_OFF', 'R11U181_OFF', 'R11V181_OFF']
OTHERS = ['R11U175_OFF', 'R11U176_OFF', 'R11V176_TDKEYUNRES_OFF', 'R11U178_OFF', 'R11V178_OFF', 'R11U184_OFF',
          'R11V184_OFF', 'R11V185_OFF']
WIDE = ALLOFF + OTHERS
def landing_of(law):
    if law.endswith('180') or law.endswith('180v'): return 180
    if law.endswith('181') or law.endswith('181v'): return 181
    return 184
