# r11u213: the law -> switch map of the two landings under verification (pass 206 at 6e39a3fc: six r11u206 laws, no
# verifier refinement; pass 207 at 62ac216e: seven r11u207 laws, r11u207's refinement and v11u207's refinement) and
# r11u208's refinement (4acbe8a5).  Read from the sources at baf91896:
#  * src/UhdmExporter.cpp r11u206Law: R11U206_OFF or the law's own switch; read at exactly six sites (UhdmExporter x3,
#    TaskFuncEmit x1, ModuleEmit x2).  Two of the six sit under an older law's gate as well:
#    § unitClassTdEndAtInitIfcPrg206 runs inside `if (r11u202Law("R11U202_CLSTDINITEND_OFF"))` (so R11U202_OFF and
#    R11U202_CLSTDINITEND_OFF drop it too), § classScopeTdRetBuildsOwner206 requires r11u200Law("R11U200_CLASSTDRET_OFF")
#    (so R11U200_OFF, R11U202_OFF and R11U200_CLASSTDRET_OFF drop it too); § tpCastUseBindsDefDefault206 and
#    § tpArrayElemBindsDefDefault206 read § tpUseBindsDefDefault160's per-instance map.
#  * src/EmitHelpers.h r11u207On: R11U207_OFF or the law's own switch (the pass switch is cached in a static; every
#    law and r11u207's refinement § pcwElabKeepsClaim207v read it); r11v207On: R11V207_OFF or the refinement's own
#    switch (§ namedOrderLinkedDeclines207v only).  R11U207_OFF alone already writes pristine bytes for the whole
#    landing (the v11u207 refinement only declines inside § namedUnlinkedWrittenOrder207); R11V207_OFF alone re-opens
#    the break v11u207 fixed (a state that never landed).
#  * src/R208.h r11v208Law: R11V208_OFF or R11V208_OPTGTANC_OFF.
SW = {
 'tpCastUseBindsDefDefault206': ['R11U206_TPCASTDEF_OFF'],
 'tpArrayElemBindsDefDefault206': ['R11U206_TPARRELEM_OFF'],
 'unitClassTdEndAtInitIfcPrg206': ['R11U206_UTIFCPRG_OFF'],
 'classScopeTdRetBuildsOwner206': ['R11U206_CLSCOPETDRET_OFF'],
 'genScopeClassVarListed206': ['R11U206_GENCLSVAR_OFF'],
 'genScopeClassVarSpecAtName206': ['R11U206_GENCLSSPAN_OFF'],
 'hiddenBlockVarMintNoFile207': ['R11U207_HIDDENVARFILE_OFF'],
 'namedUnlinkedWrittenOrder207': ['R11U207_NAMEDORDER_OFF'],
 'namedSlotFillerRootFile207': ['R11U207_SLOTFILE_OFF'],
 'bitSelMethodCallIdxSpan207': ['R11U207_MCALLIDX_OFF'],
 'parenMethodCallPathSpan207': ['R11U207_PARENMCALL_OFF'],
 'foreachThisArrAtThisToken207': ['R11U207_FOREACHTHIS_OFF'],
 'parenCastWidthRefPkgBare207': ['R11U207_PCWPKG_OFF'],
 'pcwElabKeepsClaim207v': ['R11U207_PCWELAB_OFF'],
 'namedOrderLinkedDeclines207v': ['R11V207_NAMEDLINK_OFF'],
 'opCtxTargetAncestorBind208v': ['R11V208_OPTGTANC_OFF'],
 # r11u213's own refinement (fix.patch; read on $FIX only)
 'namedOrderProtoAboveAnyBuffer213v': ['R11V213_PROTOBUF_OFF'],
 # the older laws two of pass 206's laws sit under (scored as context only)
 'unitClassTdEndAtInit202': ['R11U202_CLSTDINITEND_OFF'],
 'classTdRetSharesTypedefTs200': ['R11U200_CLASSTDRET_OFF'],
}
PARENT = {'pcwElabKeepsClaim207v': 'parenCastWidthRefPkgBare207',
          'namedOrderLinkedDeclines207v': 'namedUnlinkedWrittenOrder207',
          'namedOrderProtoAboveAnyBuffer213v': 'namedOrderLinkedDeclines207v'}
LANDING = {206: ['R11U206_OFF'], 207: ['R11U207_OFF', 'R11V207_OFF'], 208: ['R11V208_OFF'], 213: ['R11V213_OFF']}
ALLOFF = ['R11U206_OFF', 'R11U207_OFF', 'R11V207_OFF']
OTHERS = ['R11V208_OFF']
WIDE = ALLOFF + OTHERS
TRACES = ['R11U206_TRACE', 'R11U207_TRACE', 'R11V208_TRACE', 'R11V213_TRACE']
def landing_of(law):
    if law.endswith('206'): return 206
    if law.endswith('207') or law.endswith('207v'): return 207
    if law.endswith('208v'): return 208
    if law.endswith('213v'): return 213
    return None
