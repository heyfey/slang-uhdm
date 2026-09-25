# r11u170: the law -> switch map of the three landings (passes 158, 160, 163 and their verifiers' refinements).
SW = {
 # pass 158: the r11u157 decode
 'hpSelRoute157': ['R11U157_ROUTE_OFF'], 'thisPathFormByPosition157': ['R11U157_THIS_OFF'],
 'foreachArrPathVarForm157': ['R11U157_FOREACH_OFF'], 'rootPathOwnNames157': ['R11U157_ROOT_OFF'],
 'genTgtLhsLeafOwnName157': ['R11U157_GENTGT_OFF'], 'withRecvOnlyLastScoped157': ['R11U157_WITHRECV_OFF'],
 # pass 158
 'enumAliasEndAtDimOrInitDecl158': ['R11U158_EVALIASEND_OFF'], 'genCaLhsEnumConstClone158': ['R11U158_GCALHSENUM_OFF'],
 'sizeCastCaLitMask158': ['R11U158_SCLITMASK_OFF'], 'sizeCastCaSignedSize158': ['R11U158_SCSIGNSIZE_OFF'],
 'pkgFoldLeftParenSpan158': ['R11U158_PKGLPAREN_OFF'], 'arrQueryFoldAtBound158': ['R11U158_ARRQRYLOC_OFF'],
 'aggParamFoldUnqualWholeSpan158': ['R11U158_AGGUNQSPAN_OFF'], 'methodRandomizeCallSpan158': ['R11U158_RANDSPAN_OFF'],
 # r11v158
 'sizeCastNarrowTargetAbstain158v': ['R11V158_SCNARROW_OFF'], 'sizeCastSignedLitAbstain158v': ['R11V158_SCSLIT_OFF'],
 'sizeCastNamedWidthNoCast158v': ['R11V158_SCNAMEDW_OFF'], 'arrQueryParamArgOnly158v': ['R11V158_AQPARAM_OFF'],
 # pass 160
 'ppMacroBodyLines160': ['R11U160_PPINACTIVE_OFF', 'R11U160_PPARGNL_OFF', 'R11U160_PPBUILTIN_OFF', 'R11U160_PPSTRINGIFY_OFF',
                         'R11U160_PPPASTE_OFF', 'R11U160_PPNESTCOL_OFF', 'R11U160_PPPUSHLINE_OFF'],
 'objMacroParenArgsTrimmed160': ['R11U160_OBJMACROPAREN_OFF'], 'tpCloneWholeLhsBare160': ['R11U160_TPWHOLELHS_OFF'],
 'defNetTypeParamPackedVec160': ['R11U160_TPPACKEDVEC_OFF'], 'bodyTypeParamDefaultBound160': ['R11U160_BODYTPDEF_OFF'],
 'tpUseBindsDefDefault160': ['R11U160_TPUSEDEF_OFF', 'R11U160_TPUSEUNIT_OFF'],
 'implNetBareParamElab160': ['R11U160_IMPLBAREPARAM_OFF'], 'uncaughtExitsReject160': ['R11U160_CATCH_OFF'],
 # v11u160
 'pasteChainRunning160v': ['R11V160_PASTECHAIN_OFF'], 'tpWholeLhsInstantiatedOnly160v': ['R11V160_TPWHOLEUNINST_OFF'],
 # pass 163
 'elabAggFoldYCopyDefNamed163': ['R11U163_AGGFOLDYNAME_OFF'], 'aggParamFoldQualSpanByView163': ['R11U163_AGGQUALSPAN_OFF'],
 'elabOvArrFoldSharesDefParamTs163': ['R11U163_OVARRDEFTS_OFF'], 'ovPkgPatOpInstanceCopy163': ['R11U163_OVPATCOPY_OFF'],
 'pkgPatListingCopyWhenShared163': ['R11U163_PATLISTCOPY_OFF'], 'importPatOpCloneParamNamed163': ['R11U163_IMPOPNAME_OFF'],
 'paramOpCloneRelocatedSpan163': ['R11U163_OPCLONERELOC_OFF'], 'elabTpNamedElemDimDefNamed163': ['R11U163_TPDIMDEF_OFF'],
 'elabTpDefaultDefNamed163': ['R11U163_TPDEFNAME_OFF'], 'fnParamRangeNetNoFile163': ['R11U163_FNPNETFILE_OFF'],
 # r11v163
 'ovPatOpCopyAtLocalRef163v': ['R11V163_OVLOCALREF_OFF'],
}
PARENT = {'sizeCastNarrowTargetAbstain158v': 'sizeCastCaLitMask158', 'sizeCastSignedLitAbstain158v': 'sizeCastCaLitMask158',
          'sizeCastNamedWidthNoCast158v': 'sizeCastCaLitMask158', 'arrQueryParamArgOnly158v': 'arrQueryFoldAtBound158',
          'pasteChainRunning160v': 'ppMacroBodyLines160', 'tpWholeLhsInstantiatedOnly160v': 'tpCloneWholeLhsBare160',
          'ovPatOpCopyAtLocalRef163v': 'ovPkgPatOpInstanceCopy163'}
LANDING = {158: ['R11U157_OFF', 'R11U158_OFF', 'R11V158_OFF'], 160: ['R11U160_OFF'], 163: ['R11U163_OFF', 'R11V163_OFF']}
ALLOFF = LANDING[158] + LANDING[160] + LANDING[163]
def landing_of(law):
    n = int(''.join(ch for ch in law if ch.isdigit())[-3:])
    return 158 if n in (157, 158) else n
