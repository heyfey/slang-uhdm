# r11u208: the law -> switch map of the two landings under verification (pass 202 = the ten r11u200 ground-B laws,
# eight r11u202 laws and v11u202's five refinements, 0e776f9c; pass 201 = the three r11u200 ground-A laws, six r11u201
# laws, r11u201's refinement and v11u201's three, 3668bf30) and r11u204's four refinements (93c4c999).
# Read from the sources (src/UhdmExporter.cpp r11u200Law / r11u202Law / r11v202Law; src/ExprEmit.cpp and
# src/ParamEmit.cpp their own static r11u200Law; src/EmitHelpers.h r11u201On / r11v201On; src/R204.h r11v204Law):
#  * R11U202_OFF drops EXACTLY landing 202: UhdmExporter's r11u200Law (used by TypeEmit, ModuleEmit, TaskFuncEmit,
#    UhdmExporter) reads it, r11v202Law reads it; ExprEmit's / ParamEmit's static r11u200Law do NOT.
#  * R11U200_OFF drops the r11u200 laws of BOTH grounds (landing 202's ten AND landing 201's three): it over-reaches
#    as a landing-202 switch and is needed for landing 201.
#  * R11U200_GENBITS_OFF is read by BOTH halves of § genBlockBitsKeepsSelect200 (ExprEmit, landing 201; TypeEmit,
#    landing 202): no switch drops one half alone except the landing-wide R11U202_OFF (the TypeEmit half).
#  * R11U201_OFF + R11V201_OFF leave landing 201's three r11u200 laws ON; landing 201 exactly = those two +
#    R11U200_NEWARRHP_OFF R11U200_UNITFOLD_OFF R11U200_FOLDDEPTH_OFF + (the elaborated GENBITS half, not separable).
#  * R11V202_OFF is redundant beside R11U202_OFF (r11v202Law reads both).
SW = {
 # landing 202 (0e776f9c): the r11u200 ground-B laws
 'tfSigningSpanFollowsCompilePath200': ['R11U200_SIGNSPAN_OFF'],
 'defGenInitRhsKeepsParent200': ['R11U200_GENINIT_OFF'],
 'ifaceArrPortElemViewNamedByArray200': ['R11U200_IFARRNAME_OFF'],
 'implicitTsEndCrossesLineBreak200': ['R11U200_IMPLEND_OFF'],
 'defPortPackedTsKeepsWholeSpan200': ['R11U200_PORTPACKED_OFF'],
 'unitBoundFoldAtLeftOperand200': ['R11U200_UNITINIT_OFF', 'R11U200_UNITFOLD_OFF', 'R11U200_FOLDDEPTH_OFF'],
 'classTdRetSharesTypedefTs200': ['R11U200_CLASSTDRET_OFF'],
 'posOpConnKeepsRefModule200': ['R11U200_POSREFMOD_OFF'],
 'genBlockBitsKeepsSelect200': ['R11U200_GENBITS_OFF'],
 'modGenericClassListedAtDefault200': ['R11U200_CLASSCRASH_OFF'],
 # landing 202: r11u202
 'unitClassTdSpecAtName202': ['R11U202_UNITCLSTD_OFF'],
 'unitClassTdEndAtInit202': ['R11U202_CLSTDINITEND_OFF'],
 'classSpecExprArgUnlocated202': ['R11U202_SPECARGS_OFF'],
 'classValueParamIntSigned202': ['R11U202_CLSPARAMSIGN_OFF'],
 'modPkgGenericSpecNamedBare202': ['R11U202_MODPKGSPEC_OFF'],
 'modSpecValueArgSpanAtName202': ['R11U202_VALSPECSPAN_OFF'],
 'genVarInitOuterRefUnbound202': ['R11U202_GENINITBIND_OFF'],
 'defGenInitBitSelAtIndex202': ['R11U202_GENINITBS_OFF'],
 # landing 202: v11u202
 'portPackedBareImplicitTruncates202v': ['R11V202_PORTIMPL_OFF'],
 'classTdRetVarKeepsWrittenLoc202v': ['R11V202_TDRETVAR_OFF'],
 'implicitTsEndAfterLineComment202v': ['R11V202_IMPLCMT_OFF'],
 'implicitTsEndSkipsCarriageReturn202v': ['R11V202_IMPLCR_OFF'],
 'modSpecValueArgDefViewMultiArg202v': ['R11V202_VALSPECDEF_OFF'],
 # landing 201 (3668bf30): the r11u200 ground-A laws (unitBoundFold / genBlockBits above: their switches span both)
 'newArrayArgPathElemsStripped200': ['R11U200_NEWARRHP_OFF'],
 'newArrayPathStripTrailOnly201v': ['R11U201_NEWARRLAST_OFF'],
 'clsScopedBoundWholeSpan201': ['R11U201_CLSBOUND_OFF'],
 'sysCtxRefArgBare201': ['R11U201_SYSARG_OFF'],
 'opCtxRefArgBare201': ['R11U201_OPARG_OFF'],
 'nonReduceOpArgBare201': ['R11U201_NONRED_OFF'],
 'methodArgNestedRefChain201': ['R11U201_MARGNEST_OFF'],
 'callArgInSelIdxChainName201': ['R11U201_SELIDXCALL_OFF'],
 'opCtxBindableTarget201v': ['R11V201_OPTGT_OFF'],
 'clsScopedBoundPlainClass201v': ['R11V201_CLSPARAM_OFF'],
 'newArrayKeepFrozenBare201v': ['R11V201_NEWARRBARE_OFF'],
 # r11u204 refinements and the pass-196 partner of the cross-ground pair
 'memberFormalLitActualFolds204v': ['R11V204_CCLIT_OFF'],
 'dfltArgTaintExec204v': ['R11V204_DFLTTAINT_OFF'],
 'hopFoldUnaryKeepsScope204v': ['R11V204_HOPUNARY_OFF'],
 'queueTwinKeepsElem204v': ['R11V204_QTWINELEM_OFF'],
 'evalFuncOmittedDefaultKeepsCall196': ['R11U196_DFLTARG_OFF'],
 # r11u208's own refinement (fix.patch; read on $FIX only)
 'opCtxTargetAncestorBind208v': ['R11V208_OPTGTANC_OFF'],
}
PARENT = {'portPackedBareImplicitTruncates202v': 'defPortPackedTsKeepsWholeSpan200',
          'classTdRetVarKeepsWrittenLoc202v': 'classTdRetSharesTypedefTs200',
          'implicitTsEndAfterLineComment202v': 'implicitTsEndCrossesLineBreak200',
          'implicitTsEndSkipsCarriageReturn202v': 'implicitTsEndCrossesLineBreak200',
          'modSpecValueArgDefViewMultiArg202v': 'modSpecValueArgSpanAtName202',
          'newArrayPathStripTrailOnly201v': 'newArrayArgPathElemsStripped200',
          'newArrayKeepFrozenBare201v': 'newArrayPathStripTrailOnly201v',
          'opCtxBindableTarget201v': 'opCtxRefArgBare201',
          'clsScopedBoundPlainClass201v': 'clsScopedBoundWholeSpan201',
          'opCtxTargetAncestorBind208v': 'opCtxBindableTarget201v'}
LANDING = {202: ['R11U202_OFF'],
           201: ['R11U201_OFF', 'R11V201_OFF', 'R11U200_NEWARRHP_OFF', 'R11U200_UNITFOLD_OFF', 'R11U200_FOLDDEPTH_OFF'],
           204: ['R11V204_OFF']}
ALLOFF = ['R11U200_OFF', 'R11U202_OFF', 'R11V202_OFF', 'R11U201_OFF', 'R11V201_OFF']
OTHERS = ['R11V204_OFF']
WIDE = ALLOFF + OTHERS
TRACES = ['R11V208_TRACE', 'R11U200_TRACE', 'R11U202_TRACE', 'R11U201_TRACE', 'R11V204_TRACE', 'R11U196_TRACE', 'R11U198_TRACE']
L202 = {k for k in SW if (k.endswith('202') or k.endswith('202v'))} | {
    'tfSigningSpanFollowsCompilePath200', 'defGenInitRhsKeepsParent200', 'ifaceArrPortElemViewNamedByArray200',
    'implicitTsEndCrossesLineBreak200', 'defPortPackedTsKeepsWholeSpan200', 'classTdRetSharesTypedefTs200',
    'posOpConnKeepsRefModule200', 'modGenericClassListedAtDefault200'}
L201 = {k for k in SW if (k.endswith('201') or k.endswith('201v'))} | {'newArrayArgPathElemsStripped200'}
def landing_of(law):
    if law in L202: return 202
    if law in L201: return 201
    if law.endswith('204v'): return 204
    if law.endswith('208v'): return None
    if law in ('unitBoundFoldAtLeftOperand200', 'genBlockBitsKeepsSelect200'): return 'X'   # both grounds
    return None
