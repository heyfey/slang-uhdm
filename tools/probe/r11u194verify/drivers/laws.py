# r11u194: the law -> switch map of the two landings under verification (pass 184 = nine r11u184 laws + r11v184's two
# refinements, 44393367; pass 186 = the thirteen r11u183 ground-B laws + seven r11u186 laws + four refinements,
# c168c209), and the partners the composition census switches (passes 180, 181, 187, 188, r11u190's refinements).
SW = {
 # landing 184 (44393367)
 'genLocalEnumConstShared184': ['R11U184_GENENUM_OFF'],
 'tpEnumCopyAtTypedef184': ['R11U184_TPENUM_OFF'],
 'tpEnumCaDistinguisher184': ['R11U184_TPENUMCA_OFF'],        # the continuous-assignment branch of the law above
 'memberSelParenIdxSpan184': ['R11U184_MEMPAREN_OFF'],
 'incDecMemberSelIsLvalue184': ['R11U184_INCDECSEL_OFF'],
 'lvIdxMemberSelIsRead184': ['R11U184_LVIDXSEL_OFF'],
 'genScopeTrailSelNameLate184': ['R11U184_GSTRAIL_OFF'],
 'rootLvalueSpanAtRoot184': ['R11U184_ROOTLV_OFF'],
 'streamLvMemberPathRead184': ['R11U184_STREAMRD_OFF'],
 'hpIdxCallNameSpan184': ['R11U184_HPIDXCALL_OFF'],
 'incDecSelTopRestore184v': ['R11V184_IDTOP_OFF'],
 'tpEnumCaBindsInstVar184v': ['R11V184_TPCA_OFF'],
 # landing 186 (c168c209): the r11u183 ground-B laws (a switch named in ExprEmit/StmtEmit too is noted in README)
 'assocPromotedBoundAtBracket183': ['R11U183_ASSOCBRACKET_OFF'],
 'pkgParamFoldOwnTs183': ['R11U183_PKGPARAMTS_OFF'],
 'pkgParamElabCaSharesDefFold183': ['R11U183_ELABCAFOLD_OFF'],
 'aliasOfTdSharedKeepsModName183': ['R11U183_ALIASNAME_OFF'],
 'classPropElemClassTsAtType183': ['R11U183_PROPELEM_OFF'],
 'foreachAssocLoopVarIdxTs183': ['R11U183_FEIDX_OFF'],
 'typeParamUseSharesOwnTs183': ['R11U183_TYPEPARAM_OFF'],
 'importNetTsToInitEnd183': ['R11U183_IMPNETTS_OFF'],
 'ifaceArrPortSizeDimAtExpr183': ['R11U183_IFARR_OFF'],
 'foreachAssocLocalSharesDeclTs183': ['R11U183_UARANGE_OFF'],
 'macroPathTokSpans183': ['R11U183_PATHSPAN_OFF'],
 'memberBareTdAliasNamedByUse183': ['R11U183_BITTSNAME_OFF'],
 'classImportParamOwnRefs183': ['R11U183_IMPCOPY_OFF'],
 # landing 186: this pass's own laws and refinements
 'enumConstUnderscoreDropped186': ['R11U186_ENUMUS_OFF'],
 'synLitUnderscoreDropped186': ['R11U186_SYNUS_OFF'],
 'boundLitUnderscoreDropped186': ['R11U186_BOUNDUS_OFF'],
 'classPropElemQualTs186': ['R11U186_PROPELEMQUAL_OFF'],
 'ifaceTwoPkgTdNameOrder186': ['R11U186_IFACE2PKG_OFF'],
 'lawSCopyIdOrder186': ['R11U186_LAWSSORT_OFF'],
 'rootElemAtNextTok186': ['R11U186_ROOTELEM_OFF'],
 'macroPathTokOneBuffer186': ['R11U186_PATHBUF_OFF'],
 'assocBracketPkgOnly186': ['R11U186_ASSOCPKG_OFF'],
 'typeParamGateNoLookup186': ['R11U186_TPGATE_OFF'],
 'typeParamDefersToTpUse186': ['R11U186_TPDEFER_OFF'],
 # cross-ground partners
 'classTpKeywordTsAtDefault188': ['R11U188_TPKEYWORD_OFF'],
 'tpFormalMacroAtExpansion188v': ['R11V188_MACROEXP_OFF'],
 'nestRdIdxOnly190v': ['R11V190_NESTIDX_OFF'],
 'trailIdxCallArgNamesByPath187': ['R11U187_TRAILCALL_OFF'],
 'trailIdxSelNamesByPath187': ['R11U187_TRAILSEL_OFF'],
 'classTpDefaultTsAtUse180': ['R11U180_TPUSE_OFF'],
 'incDecMixedPathIsLvalue181': ['R11U181_INCDECMIX_OFF'],
 'lvIdxMixedPathIsRead181': ['R11U181_LVIDXREAD_OFF'],
 'rootNetPathOwnNames181': ['R11U181_ROOTNET_OFF'],
 'bareDecUnderscoreDropped181': ['R11U181_DECUS_OFF'],
}
PARENT = {'tpEnumCaDistinguisher184': 'tpEnumCopyAtTypedef184',
          'tpEnumCaBindsInstVar184v': 'tpEnumCopyAtTypedef184',
          'incDecSelTopRestore184v': 'incDecMemberSelIsLvalue184',
          'macroPathTokOneBuffer186': 'macroPathTokSpans183',
          'assocBracketPkgOnly186': 'assocPromotedBoundAtBracket183',
          'typeParamGateNoLookup186': 'typeParamUseSharesOwnTs183',
          'typeParamDefersToTpUse186': 'typeParamUseSharesOwnTs183',
          'nestRdIdxOnly190v': 'lvIdxMixedPathIsRead181'}
LANDING = {184: ['R11U184_OFF', 'R11V184_OFF'],
           186: ['R11U183_OFF', 'R11U186_OFF'],           # R11U183_OFF spans pass 187's ground-A r11u183 laws too
           187: ['R11U187_OFF'],
           188: ['R11U188_OFF', 'R11V188_OFF'],
           180: ['R11U180_OFF', 'R11V180_OFF'],
           181: ['R11U181_OFF', 'R11V181_OFF'],
           190: ['R11V190_OFF']}
ALLOFF = LANDING[184] + LANDING[186]
OTHERS = ['R11U180_OFF', 'R11V180_OFF', 'R11U181_OFF', 'R11V181_OFF', 'R11U187_OFF', 'R11U188_OFF', 'R11V188_OFF',
          'R11V190_OFF']
WIDE = ALLOFF + OTHERS
def landing_of(law):
    for n in (184, 186, 187, 188, 180, 181, 190):
        if law.endswith(str(n)) or law.endswith(f'{n}v'): return n
    if law.endswith('183'): return 186
    return None
