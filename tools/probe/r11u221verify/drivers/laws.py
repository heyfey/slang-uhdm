# r11u221: the law -> switch map of the two landings under verification, read from the sources at 57ce3ae8:
#  * pass 216 (c4f26079, module/type ground): src/UhdmExporter.cpp r11u216Law (R11U216_OFF or the law's own switch;
#    ModuleEmit.cpp declares and calls it) and r11v216Law (R11V216_OFF or the refinement's own switch; it does NOT read
#    R11U216_OFF, but both refinements run only inside a pass-216 law's application, so R11U216_OFF alone restores the
#    pristine bytes).  R11U216_TFOUTCLS_OFF also drops § tfArgImportCloneFollows216 (it runs only where the outside
#    order fired: the r11u216 README).  R11U216_TRACE=<dir> traces every firing (<pid>.216).
#  * pass 215 (57ce3ae8, expression/parameter ground): src/EmitHelpers.h r11u215On (R11U215_OFF or the law's own
#    switch).  The two refinements read plain getenv: R11V215_MEMBERREAD_OFF (ParamEmit.cpp, inside
#    § impPatCopyFirstListingUnparented215's application) and R11V215_ENUMVALITEM_OFF (inside the stamp); NO switch
#    R11V215_OFF exists (read nowhere), and R11U215_CASEWILDCAT_OFF is read nowhere (the law was dropped at
#    integration for § caseItemWildConcatOnly217v).  § landingSwitchReach215 is R11V198_OFF (ExprEmit.cpp), a switch of
#    v11u198's refinement, not dropped by R11U215_OFF.  R11U215_TRACE=<dir> traces every firing (<pid>.T215).
SW = {
 # pass 216
 'genScopeRangeQueryFold216': ['R11U216_GENRQFOLD_OFF'],
 'ndaRangeQueryFold216': ['R11U216_NDARQFOLD_OFF'],
 'ndaSizeQueryFold216': ['R11U216_NDASIZEFOLD_OFF'],
 'tfArgOutsideClassOrder216': ['R11U216_TFOUTCLS_OFF'],
 'tfArgImportCloneFollows216': ['R11U216_TFIMPCLONE_OFF'],
 'tfArgOutsideClassKeyOrder216v': ['R11V216_CLSKEY_OFF'],
 'rqParamOpBoundAtCall216v': ['R11V216_PARAMOPLOC_OFF'],
 # pass 215
 'pkgTdAliasLastWriter215': ['R11U215_TDALIAS_OFF'],
 'pkgImportEnumCloneLastWriter215': ['R11U215_ENUMCLONE_OFF'],
 'enumCloneValueItemKeepsBare215v': ['R11V215_ENUMVALITEM_OFF'],
 'impPatCopyFirstListingUnparented215': ['R11U215_IMPPATFIRST_OFF'],
 'impPatMemberReadKeepsParent215v': ['R11V215_MEMBERREAD_OFF'],
 'incDecOperandKeepsLvalueForm215': ['R11U215_INCDECROUTE_OFF'],
 'opIdxRecvElemFollowsPath215': ['R11U215_OPIDXRECV_OFF'],
 'opIdxRecvPlainElab215': ['R11U215_OPIDXRECVELAB_OFF'],
 # the landed refinement composed with pass 216 (r11u217, 0a682d73) and the pass-212 stamp it refines
 'ndaQueryFoldsNoStamp217v': ['R11V217_NDAQUERY_OFF'],
 'ndaSysCallNetTs212': ['R11U212_NDASYSTS_OFF'],
 # r11u221's own refinements (fix.patch; read on $FIX only)
 'ndaPortQueryKeepsStamp221v': ['R11V221_NDAPORTQRY_OFF'],
 'cloneTwinMintIdOrder221v': ['R11V221_TWINORDER_OFF'],
}
PARENT = {'tfArgOutsideClassKeyOrder216v': 'tfArgOutsideClassOrder216',
          'rqParamOpBoundAtCall216v': 'genScopeRangeQueryFold216',
          'enumCloneValueItemKeepsBare215v': 'pkgImportEnumCloneLastWriter215',
          'impPatMemberReadKeepsParent215v': 'impPatCopyFirstListingUnparented215',
          'opIdxRecvPlainElab215': 'opIdxRecvElemFollowsPath215',
          'ndaQueryFoldsNoStamp217v': 'ndaSysCallNetTs212',
          'ndaPortQueryKeepsStamp221v': 'ndaQueryFoldsNoStamp217v'}
LAND = {}
for _l in SW:
    if _l.endswith('221v'): LAND[_l] = 221
    elif _l.endswith('217v'): LAND[_l] = 217
    elif _l.endswith('212'): LAND[_l] = 212
    elif _l.endswith('216') or _l.endswith('216v'): LAND[_l] = 216
    elif _l.endswith('215') or _l.endswith('215v'): LAND[_l] = 215
LANDING = {216: ['R11U216_OFF', 'R11V216_OFF'], 215: ['R11U215_OFF'], 221: ['R11V221_OFF'], 217: ['R11V217_OFF'], 212: ['R11U212_OFF', 'R11V212_OFF']}
ALLOFF = ['R11U216_OFF', 'R11V216_OFF', 'R11U215_OFF']
OTHERS = []
WIDE = ALLOFF + ['R11V215_ENUMVALITEM_OFF', 'R11V215_MEMBERREAD_OFF']   # (inert under R11U215_OFF: a check of reach)
TRACES = ['R11U216_TRACE', 'R11U215_TRACE', 'R11V221_TRACE', 'R11V217_TRACE', 'R11U212_TRACE']
def landing_of(law):
    return LAND.get(law)
