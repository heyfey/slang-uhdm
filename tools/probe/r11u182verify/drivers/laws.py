# r11u182: the law -> switch map of the two landings under verification (pass 171 = r11u172's three TypeEmit laws +
# seven r11u171 laws + v11u171's two refinements, 72fd3061; pass 174 = r11u172's DEPTH law + three r11u174 laws +
# r11v174's refinement, 38d03148), and of the landings the composition census also switches (passes 166/168/169,
# r11u173's and r11u177's refinements).
SW = {
 # landing 171 (72fd3061)
 'tdMoveCarriesFile172': ['R11U172_FILE_OFF'], 'boundLitWrittenDigits172': ['R11U172_VALUE_OFF'],
 'sysSignNameSpanSyntax172': ['R11U172_SPAN_OFF'],
 'castUnionCloneFile171': ['R11U171_CASTUNIONFILE_OFF'], 'tsMemberRootFile171': ['R11U171_MEMBERROOTFILE_OFF'],
 'splitPortTsKeyOnPortDecl171': ['R11U171_SPLITPORTKEY_OFF'], 'selLhsBareDecRhsShared171': ['R11U171_SELDECSHARE_OFF'],
 'udpFormConcatSwallowSpans171': ['R11U171_UDPSWALLOW_OFF'], 'defNetEndOutputCol171': ['R11U171_NETENDCOL_OFF'],
 'genElseIfGateTermPath171': ['R11U171_GENELSEIF_OFF'],
 'udpSwallowLvalueOnly171v': ['R11V171_UDPLVALUE_OFF'], 'genElseIfFlatOnly171v': ['R11V171_GENFLAT_OFF'],
 # landing 174 (38d03148)
 'pkgFnCastTopListing172': ['R11U172_DEPTH_OFF'], 'elabParamLeftoverRefUnnamed174': ['R11U174_LEFTREF_OFF'],
 'asmRefQualWholeSpanElab174': ['R11U174_ASMSPAN_OFF'], 'elabStructMemberOpFoldUnlocated174': ['R11U174_MOPUNLOC_OFF'],
 'mopPkgBaseReduces174v': ['R11V174_MOPPKG_OFF'],
 # cross-ground partners (passes 169 and r11u177)
 'memLeftFormalArgLoc169': ['R11U169_MLARGLOC_OFF'], 'mlArgLocFileAtActual177v': ['R11V177_MLARGFILE_OFF'],
 'genCaFoldTsChainNamed169': ['R11U169_GCACHAIN_OFF'],
}
PARENT = {'udpSwallowLvalueOnly171v': 'udpFormConcatSwallowSpans171', 'genElseIfFlatOnly171v': 'genElseIfGateTermPath171',
          'mopPkgBaseReduces174v': 'elabStructMemberOpFoldUnlocated174'}
LANDING = {171: ['R11U172_FILE_OFF', 'R11U172_VALUE_OFF', 'R11U172_SPAN_OFF', 'R11U171_OFF', 'R11V171_OFF'],
           174: ['R11U174_OFF'],
           169: ['R11U169_OFF'], 177: ['R11V177_OFF']}
ALLOFF = ['R11U172_OFF', 'R11U171_OFF', 'R11V171_OFF', 'R11U174_OFF']
PREOFF = ALLOFF + ['R11V177_OFF']          # must equal the 50a01bc3 build byte for byte
WIDE = ALLOFF + ['R11U166_OFF', 'R11U168_OFF', 'R11U169_OFF', 'R11V173_OFF', 'R11V177_OFF']
L171 = {'tdMoveCarriesFile172', 'boundLitWrittenDigits172', 'sysSignNameSpanSyntax172', 'castUnionCloneFile171',
        'tsMemberRootFile171', 'splitPortTsKeyOnPortDecl171', 'selLhsBareDecRhsShared171', 'udpFormConcatSwallowSpans171',
        'defNetEndOutputCol171', 'genElseIfGateTermPath171', 'udpSwallowLvalueOnly171v', 'genElseIfFlatOnly171v'}
L174 = {'pkgFnCastTopListing172', 'elabParamLeftoverRefUnnamed174', 'asmRefQualWholeSpanElab174',
        'elabStructMemberOpFoldUnlocated174', 'mopPkgBaseReduces174v'}
def landing_of(law):
    if law in L171: return 171
    if law in L174: return 174
    if law.endswith('177v'): return 177
    return 169
