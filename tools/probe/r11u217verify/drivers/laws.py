# r11u217: the law -> switch map of the three landings under verification, read from the sources at 83ee16d6:
#  * pass 209 (b69dc2da, module/type ground): src/UhdmExporter.cpp r11u209Law (R11U209_OFF or the law's own switch),
#    r11u205Law (R11U205_OFF or R11U209_OFF or the law's own switch: the three r11u205 ground-B laws), r11v209Law
#    (R11V209_OFF or R11U209_OFF or the refinement's own switch).  Several sit under an older law's state as well:
#    § defGenTargetIpsDefName205 needs pass 161's `sel161 && name161` (R11U161_ROUTE_OFF / R11U161_NAME_OFF drop it
#    too), § tfItemLocalSpecAtName209 needs pass 142's tfItemLocalClassTs142 and pass 53's pkgGeneric53,
#    § classTdPkgEnumMemberShares209 runs only where § aggMemberAggTdSharesListing3's unban3 did not already share,
#    § mpOrphanLaterWriter209v reads the writer positions ModuleEmit's § ifaceSigConnNamedByChildPort155 notes.
#  * pass 210 (a727b8c7, expression/parameter ground): src/EmitHelpers.h r11u210On (R11U210_OFF or the law's own
#    switch, cached) and r11u205aOn (R11U205_OFF or R11U210_OFF or R11U205_IFARRIDX_OFF: § elabIfArrIdxChainName205).
#    R11U210_LANDING201_OFF / R11U210_GENBITS201_OFF are switches of landing 201's state (no law of this pass).
#  * pass 212 (745f66ab, module/type ground): src/UhdmExporter.cpp r11u212Law (R11U212_OFF or the law's own switch)
#    and r11v212Law (R11V212_OFF or the refinement's own switch; it does NOT read R11U212_OFF, but the refinement
#    only runs inside § anonMemberTdLastWriter212's application, so R11U212_OFF alone restores pristine bytes).
#  * R11U205_OFF spans both grounds: pass 209's three r11u205 laws AND pass 210's § elabIfArrIdxChainName205.
SW = {
 # pass 209
 'genConnTrailSelChain205': ['R11U205_GENIDXSEL_OFF'],
 'defGenTargetIpsDefName205': ['R11U205_IPSNAME_OFF'],
 'ifacePortDeclTsAtPortDecl205': ['R11U205_PORTDECLTS_OFF'],
 'twinElemOnlyNoRange209': ['R11U209_TWINELEM_OFF'],
 'pkgArrTdElemClone209': ['R11U209_ARRTDCLONE_OFF'],
 'portConnOpLeafChain209': ['R11U209_OPLEAFCHAIN_OFF'],
 'modportOpOrphanReparent209': ['R11U209_MPORPHAN_OFF'],
 'tfItemInitLocalAtType209': ['R11U209_TFINITTYPE_OFF'],
 'tfItemLocalSpecAtName209': ['R11U209_TFSPECNAME_OFF'],
 'classTdPkgEnumMemberShares209': ['R11U209_CLSENUMMEM_OFF'],
 'mpOrphanSkipConcat209v': ['R11V209_MPCONCAT_OFF'],
 'mpOrphanLaterWriter209v': ['R11V209_MPLATER_OFF'],
 'pdTsNotTypedefListing209v': ['R11V209_PDNAMED_OFF'],
 # pass 210
 'elabIfArrIdxChainName205': ['R11U205_IFARRIDX_OFF'],
 'elabIfArrIdxExprChainName210': ['R11U210_IFARREXPR_OFF'],
 'memLeftReadsPatUnlocated210': ['R11U210_MLPATLOC_OFF'],
 'pkgTopWidePatReplTsName210': ['R11U210_PKGREPLTS_OFF'],
 'caseItemImpWildParamScopeName210': ['R11U210_CASEWILD_OFF'],
 'pkgImpParamMemberColons210': ['R11U210_PKGIMPCOLON_OFF'],
 'pkgImpParamAliasColons210': ['R11U210_PKGIMPALIAS_OFF'],
 # pass 212
 'anonMemberTdLastWriter212': ['R11U212_ANONMEMTD_OFF'],
 'pkgEnumAliasListingParent212': ['R11U212_PKGENUMALIAS_OFF'],
 'queueMemberSpanToDim212': ['R11U212_QUEUEMEMSPAN_OFF'],
 'sizeDimOvrFileAtDim212': ['R11U212_SIZEDIMFILE_OFF'],
 'signCastSysCallLhsTs212': ['R11U212_SIGNCASTTS_OFF'],
 'ndaSysCallNetTs212': ['R11U212_NDASYSTS_OFF'],
 'anonMemberTdOwnerDef212v': ['R11V212_TDOWNER_OFF'],
 # r11u217's own refinements (fix.patch; read on $FIX only)
 'anonMemberTdUseCopyKeeps217v': ['R11V217_TDUSECOPY_OFF'],
 'ifacePortDeclFoldedBoundLeftOp217v': ['R11V217_PDBOUNDOP_OFF'],
 'ndaQueryFoldsNoStamp217v': ['R11V217_NDAQUERY_OFF'],
 'caseItemWildConcatOnly217v': ['R11V217_CASEWILDCAT_OFF'],
}
PARENT = {'mpOrphanSkipConcat209v': 'modportOpOrphanReparent209',
          'mpOrphanLaterWriter209v': 'modportOpOrphanReparent209',
          'pdTsNotTypedefListing209v': 'ifacePortDeclTsAtPortDecl205',
          'anonMemberTdOwnerDef212v': 'anonMemberTdLastWriter212',
          'anonMemberTdUseCopyKeeps217v': 'anonMemberTdLastWriter212',
          'ifacePortDeclFoldedBoundLeftOp217v': 'ifacePortDeclTsAtPortDecl205',
          'ndaQueryFoldsNoStamp217v': 'ndaSysCallNetTs212',
          'caseItemWildConcatOnly217v': 'caseItemImpWildParamScopeName210'}
LAND = {}
for _l in SW:
    if _l.endswith('217v'): LAND[_l] = 217
    elif _l.endswith('212') or _l.endswith('212v'): LAND[_l] = 212
    elif _l.endswith('210') or _l == 'elabIfArrIdxChainName205': LAND[_l] = 210
    elif _l.endswith('209') or _l.endswith('209v') or _l.endswith('205'): LAND[_l] = 209
LANDING = {209: ['R11U209_OFF', 'R11V209_OFF'], 210: ['R11U210_OFF'], 212: ['R11U212_OFF', 'R11V212_OFF'], 217: ['R11V217_OFF']}
ALLOFF = ['R11U209_OFF', 'R11V209_OFF', 'R11U210_OFF', 'R11U205_IFARRIDX_OFF', 'R11U212_OFF', 'R11V212_OFF']
OTHERS = ['R11V213_OFF']
WIDE = ALLOFF + OTHERS
TRACES = ['R11U209_TRACE', 'R11U210_TRACE', 'R11U212_TRACE', 'R11V217_TRACE']
def landing_of(law):
    return LAND.get(law)
