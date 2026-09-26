# r11u173: the law -> switch map of the two landings (pass 164 with the r11u161 decode and v11u164's refinements;
# pass 167 with r11v167's refinement) and of r11u170's refinements that landed between them.
SW = {
 # r11u161 decode (landed with pass 164)
 'defGenPathSel161': ['R11U161_ROUTE_OFF'], 'firstOrderedPathSel161': ['R11U161_PORT_OFF'],
 'enumAliasClone161': ['R11U161_ALIAS_OFF'],
 # pass 164
 'rangeQueryFoldUnconverted164': ['R11U164_RANGEQ_OFF'], 'rangeQueryDeclNetSize164': ['R11U164_RANGEQSIZE_OFF'],
 'caDelayFirstOnly164': ['R11U164_CADELAY_OFF'], 'caDelayParamElabFresh164': ['R11U164_DLYPARAMELAB_OFF'],
 'modportPortViewParamDef164': ['R11U164_PVMPDEF_OFF'], 'portViewParamShared164': ['R11U164_PVSHARE_OFF'],
 'defGenSelBaseLeafAtIndex164': ['R11U164_SELBASELEAF_OFF'], 'bindUnresolvedPathNoName164': ['R11U164_BINDPATHNAME_OFF'],
 'genNetDeclAssignLhsShared164': ['R11U164_GENNDAHP_OFF'],
 # v11u164
 'enumAliasBaseAsTarget164v': ['R11V164_ALIASBASE_OFF'], 'rangeQueryVarDeclMask164v': ['R11V164_RQMASK_OFF'],
 # pass 167
 'tpAnonStructLastParamUser167': ['R11U167_TPSTRUCTUSE_OFF'], 'tpAnonStructCopySpanAtKeyword167': ['R11U167_TPSTRUCTSPAN_OFF'],
 'pkgPatCallArgReadNoParent167': ['R11U167_PATCALLARG_OFF'], 'evalFuncBodyRhsStampClone167': ['R11U167_S2CLONE_OFF'],
 'genProcFoldDeclTsScopeNamed167': ['R11U167_GSFOLDDECLTS_OFF'], 'hpDotWsTrimmed167': ['R11U167_HPWS_OFF'],
 # r11v167
 's2ClonePrecheck167v': ['R11V167_S2PRECHECK_OFF'],
 # pass 157/158 (cross pairs only)
 'hpSelRoute157': ['R11U157_ROUTE_OFF'], 'arrQueryFoldAtBound158': ['R11U158_ARRQRYLOC_OFF'],
}
PARENT = {'enumAliasBaseAsTarget164v': 'enumAliasClone161', 'rangeQueryVarDeclMask164v': 'rangeQueryDeclNetSize164',
          's2ClonePrecheck167v': 'evalFuncBodyRhsStampClone167'}
LANDING = {164: ['R11U161_OFF', 'R11U164_OFF'], 167: ['R11U167_OFF'], 158: ['R11U157_OFF', 'R11U158_OFF', 'R11V158_OFF']}
ALLOFF = LANDING[164] + LANDING[167]
def landing_of(law):
    n = int(''.join(ch for ch in law if ch.isdigit())[-3:])
    return 164 if n in (161, 164) else 158 if n in (157, 158) else n
