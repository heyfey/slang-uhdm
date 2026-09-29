# r11u226: the law -> switch map of the three landings under verification, read from the sources at 4a620bd0:
#  * landing 219 (896ec643, module/type ground): UhdmExporter.cpp r11u214Law (R11U214_OFF or R11U219_OFF or the law's
#    own switch; TypeEmit, TaskFuncEmit, ModuleEmit call it), r11u219Law (R11U219_OFF or own), r11v219Law (R11V219_OFF
#    or R11U219_OFF or own).  R11U219_OFF therefore drops the r11u214 laws, pass 219's laws and v11u219's refinement.
#    The landing switches R11U219_LANDING202/212/216_OFF are NOT read by R11U219_OFF (they drop earlier landings).
#  * landing 220 (551c9751, expression/parameter ground): src/R218.h r11u218On (R11U218_OFF or R11U220_OFF or own),
#    src/R220.h r11u220On (R11U220_OFF or own).  R11U220_OFF drops the four r11u218 laws AND the nine pass-220 laws;
#    R11U218_OFF drops the r11u218 laws alone.  R11U220_LANDING205A_OFF is NOT read by R11U220_OFF.
#  * landing 223 (75a564b0, module/type ground): src/R223.h r11u223Law (R11U223_OFF or own), r11v223Law (R11V223_OFF
#    or R11U223_OFF or own).  R11U223_OFF drops pass 223's five laws and v11u223's two refinements.
SW = {
 # landing 219: the r11u214 laws
 'enumTdLastWriter214': ['R11U214_SEQARBNAME_OFF', 'R11U214_ENUMPKGW_OFF', 'R11U214_ENUMCLSW_OFF',
                         'R11U214_ENUMALIASGRP_OFF', 'R11U214_ENUMALIASNAME_OFF'],
 'classTdAliasLastWriter214': ['R11U214_CLASSTDW_OFF'],
 'classScopeTdPkgListingParent214': ['R11U214_CLSSCOPETD_OFF'],
 'cloneAliasFormalOwnChain214': ['R11U214_CLONENAME_OFF'],
 'modStructMemberQualSpan214': ['R11U214_QUALSPAN_OFF'],
 'unitImportCopyOwnTsRef214': ['R11U214_UNITCOPYTS_OFF'],
 'unitImportCopyValueFollowsPkg214': ['R11U214_VALENC_OFF'],
 'importVarElemOwnName214': ['R11U214_IMPVARELEM_OFF'],
 # landing 219: pass 219's laws and v11u219's refinement
 'enumClsWriterUnitScopeOnly219': ['R11U219_UNITCLSONLY_OFF'],
 'enumPkgWriterImportsType219': ['R11U219_PKGWIMPORT_OFF'],
 'ndaSizeFoldReach219': ['R11U219_SIZE2D_OFF', 'R11U219_SIZEDIM_OFF'],
 'sizeReachFollowsWalker219v': ['R11V219_SIZEWALK_OFF'],
 'defGenTargetIpsSelArm219': ['R11U219_IPSSELARM_OFF'],
 'ppIdentEndInRebuiltText219': ['R11U219_PPIDENTEND_OFF'],
 'ppDotNameAfterArgToken219': ['R11U219_PPDOTNAME_OFF'],
 # landing 220: the r11u218 laws and pass 220's
 'pkgQualOperandSpanInParam218': ['R11U218_QUALSPAN_OFF'],
 'lvIdxPathRangeTailIsRead218': ['R11U218_LVIDXPS_OFF'],
 'hpTrailIpsNamesByPath218': ['R11U218_HPIPSNAME_OFF'],
 'importCloneSharesHomeReturn218': ['R11U218_CLONERET_OFF'],
 'hpVarSelRangeIdxNamesByPath220': ['R11U220_HPVSIDX_OFF'],
 'hpVarSelIpsDirectRefSkipsSelect220': ['R11U220_HPVSIPS_OFF'],
 'hpVarSelColumnJoin220': ['R11U220_HPVSCOL_OFF'],
 'strLitShiftNeedsBacktick220': ['R11U220_STRSHIFT_OFF'],
 'strLitContLineSpan220': ['R11U220_STRCONT_OFF'],
 'newArrayCallArgStripped220': ['R11U220_NEWARRCALL_OFF'],
 'newArrayBitSelIdxStripped220': ['R11U220_NEWARRIDX_OFF'],
 'cloneHpIdxNamesByChain220': ['R11U220_CLONEIDX_OFF'],
 'cloneIdxOwnCopyOnly220': ['R11U220_CLONEIDX_OFF'],
 # landing 223: pass 223's laws and v11u223's refinements
 'tfArgScalarTdWriter223': ['R11U223_SCALARTDTOK_OFF'],
 'tfArgScalarTdExportFirst223': ['R11U223_SCALARTDEXP_OFF'],
 'fixedOuterAssocInnerReg223': ['R11U223_ASSOCREG_OFF'],
 'unsizedInnerSizeDeclines223': ['R11U223_SIZEDECLINE_OFF'],
 'ndaAdjSizeFoldSized223': ['R11U223_ADJSIZE_OFF'],
 'sizeDeclineTsInvalid223v': ['R11V223_SIZEINVALID_OFF'],
 'formalRegNoHeap223v': ['R11V223_DETREG_OFF'],
 # r11u226's own refinements (fix.patch; read on $FIX only) are added here if a break is proven
}
PARENT = {'enumClsWriterUnitScopeOnly219': 'enumTdLastWriter214',
          'enumPkgWriterImportsType219': 'enumTdLastWriter214',
          'sizeReachFollowsWalker219v': 'ndaSizeFoldReach219',
          'cloneIdxOwnCopyOnly220': 'cloneHpIdxNamesByChain220',
          'tfArgScalarTdExportFirst223': 'tfArgScalarTdWriter223',
          'sizeDeclineTsInvalid223v': 'unsizedInnerSizeDeclines223',
          'formalRegNoHeap223v': 'tfArgScalarTdWriter223'}
LAND = {}
for _l in SW:
    if _l.endswith('226v'): LAND[_l] = 226
    elif _l.endswith(('214', '219', '219v')): LAND[_l] = 219
    elif _l.endswith(('218', '220')): LAND[_l] = 220
    elif _l.endswith(('223', '223v')): LAND[_l] = 223
LANDING = {219: ['R11U219_OFF'], 220: ['R11U220_OFF'], 223: ['R11U223_OFF'], 226: ['R11V226_OFF']}
ALLOFF = ['R11U219_OFF', 'R11U220_OFF', 'R11U223_OFF']
# WIDE: the three landings off and the r11u221 refinements off = the state of 57ce3ae8 (pass 220's base) plus nothing
WIDE = ALLOFF + ['R11V221_OFF']
TRACES = ['R11U214_TRACE', 'R11U219_TRACE', 'R11U218_TRACE', 'R11U220_TRACE', 'R11U223_TRACE']
def landing_of(law):
    return LAND.get(law)
