# r11u204: the law -> switch map of the two landings under verification (pass 196 = the seven r11u191 ground-B laws +
# eight r11u196 laws + v11u196's two refinements, c029f423; pass 198 = the seven r11u198 laws + v11u198's refinement,
# cffb131f) and the partners of the wide composition state (passes 193, 195, the r11u199 refinements).
# NOTE: R11U191_OFF is NOT used for landing 196: it also drops pass 195's three r11u191 ground-A laws
# (idxCallPathAtDots191, evalFuncExecCallArgTs191, pkgFoldAtLeadingLeaf191: ExprEmit r191EX / ParamEmit r191PE read
# R11U191_OFF).  R11U196_OFF drops the seven ground-B r11u191 laws (TaskFuncEmit / TypeEmit / ModuleEmit gates) and every
# r11u196 law; the v11u196 refinements live inside § evalFuncOmittedDefaultKeepsCall196.  R11V198_OFF is read nowhere
# (a no-op kept because the brief names it); § vsStampReducedCtxOnly198v lives inside § callArgVarSelStamp198.
SW = {
 # landing 196 (c029f423)
 'formalDefaultNamedThroughFormal191': ['R11U191_REFFULL_OFF'],
 'queueRetTwinDynShape191': ['R11U191_QUEUERANGE_OFF'],
 'evalFuncCastMemberKeepsCall191': ['R11U191_CONSTCALL_OFF'],
 'elabCaConstLhsSized191': ['R11U191_UNSIZEDPKG_OFF'],
 'enumDefOwnerNotInstance191': ['R11U191_ENUMPARENT_OFF'],
 'modAggClonePerDefKey191': ['R11U191_HDRTD_OFF'],
 'splitPortRealRedeclLogicTs191': ['R11U191_REALPORT_OFF'],
 'modGenericClassListed196': ['R11U196_MODGENERIC_OFF'],
 'modGenericHandleBare196': ['R11U196_MODGENHANDLE_OFF'],
 'modClassTsLinksDefListing196': ['R11U196_MODCLSLINK_OFF'],
 'classPropElemClassTsAtName196': ['R11U196_ELEMCLSNAME_OFF'],
 'retPkgQualTdNoAlias196': ['R11U196_RETQUALTD_OFF'],
 'tpArrBoundAtLeftOperand196': ['R11U196_TPARRBOUND_OFF'],
 'evalFuncOmittedDefaultKeepsCall196': ['R11U196_DFLTARG_OFF'],
 'tfFormalTdCloneFile196': ['R11U196_FORMALCLONEFILE_OFF'],
 'dfltArgExecutedRead196v': ['R11V196_DFLTEXEC_OFF'],
 'dfltArgExecutedPathEval196v': ['R11V196_DFLTEVAL_OFF'],
 # landing 198 (cffb131f)
 'genCaUnclonedFoldOwner198': ['R11U198_GSOWNER_OFF'],
 'callArgVarSelStamp198': ['R11U198_VSARG_OFF'],
 'genHopFoldSelName198': ['R11U198_HOPSEL_OFF'],
 'ovrParamBoundOpSelName198': ['R11U198_OVRBOUND_OFF'],
 'methodArgOpRefChainName198': ['R11U198_MARGOP_OFF'],
 'lvIdxCallArgIsRead198': ['R11U198_LVCALLARG_OFF'],
 'genCaCastRhsRefUnnamed198': ['R11U198_CASTRHS_OFF'],
 'vsStampReducedCtxOnly198v': ['R11V198_VSSYS_OFF'],
}
# A refinement is also scored against its parent's switch (pristine for that site).
PARENT = {'dfltArgExecutedRead196v': 'evalFuncOmittedDefaultKeepsCall196',
          'dfltArgExecutedPathEval196v': 'evalFuncOmittedDefaultKeepsCall196',
          'vsStampReducedCtxOnly198v': 'callArgVarSelStamp198'}
LANDING = {196: ['R11U196_OFF', 'R11V196_OFF'],
           198: ['R11U198_OFF', 'R11V198_OFF']}
ALLOFF = LANDING[196] + LANDING[198]
OTHERS = ['R11U193_OFF', 'R11V193_OFF', 'R11U195_OFF', 'R11V195_OFF', 'R11V199_OFF']
WIDE = ALLOFF + OTHERS
def landing_of(law):
    if law.endswith('191') or law.endswith('196') or law.endswith('196v'): return 196
    if law.endswith('198') or law.endswith('198v'): return 198
    return None
