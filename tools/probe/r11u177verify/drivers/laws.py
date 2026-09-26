# r11u177: the law -> switch map of the two landings under verification (pass 168 = the r11u166 location model +
# six r11u168 laws, f34d9d7c; pass 169 = four r11u169 laws + r11v169's refinement, 31739f79) and of the landings the
# composition census also switches (pass 164 with r11u161's decode, pass 167, r11u173's refinement).
SW = {
 # r11u166 location model (landed with pass 168)
 'ppOutputLine166': ['R11U166_LINE_OFF'], 'ppOutputCol166': ['R11U166_COL_OFF', 'R11U166_ONELINE_OFF'],
 'ppOutputFile166': ['R11U166_FILE_OFF'], 'ppOutputInclLine166': ['R11U166_INCL_OFF'],
 'ppReincludeSplice166': ['R11U166_INCL_REINC_OFF'], 'macroConnInRange166': ['R11U166_MACROCONN_OFF'],
 'ppBasedLitWsAfter166': ['R11U166_COL_LIT_OFF'],
 # pass 168
 'ppFileCallArgBody168': ['R11U168_PPFILECALL_OFF'], 'undefKeepsOtherRootMacro168': ['R11U168_UNDEFXROOT_OFF'],
 'paramBaseSelTsInstName168': ['R11U168_PSBOUNDTS_OFF'], 'hcSelIdxInstName168': ['R11U168_HCIDXNAME_OFF'],
 'structParamBoundAtPatternLeaf168': ['R11U168_SPLEAF_OFF'], 'rangeHierPathNoFullName168': ['R11U168_RNGHPNAME_OFF'],
 # pass 169 + r11v169
 'genCaFoldTsChainNamed169': ['R11U169_GCACHAIN_OFF'], 'memLeftSliceUnlocated169': ['R11U169_MLLOC_OFF'],
 'memLeftFormalArgLoc169': ['R11U169_MLARGLOC_OFF'], 'patFlatMemberLeftSpan169': ['R11U169_PATFLATSPAN_OFF'],
 'gcaChainInsideSetKeepsInst169v': ['R11V169_INSIDESET_OFF'],
 # r11u177 (this verification's refinement, fix.patch; a no-op switch on law.bin)
 'mlArgLocFileAtActual177v': ['R11V177_MLARGFILE_OFF'], 'aggFoldReanchorFile177v': ['R11V177_AGGREANCHORFILE_OFF'],
 'tagPatSortSrcOrder177v': ['R11V177_TAGSORT_OFF'],
 # r11u173 (between the two landings)
 'pvElabGenDefParamLhs173v': ['R11V173_PVELABGEN_OFF'],
}
PARENT = {'gcaChainInsideSetKeepsInst169v': 'genCaFoldTsChainNamed169', 'mlArgLocFileAtActual177v': 'memLeftFormalArgLoc169'}
LANDING = {168: ['R11U166_OFF', 'R11U168_OFF'], 169: ['R11U169_OFF'], 173: ['R11V173_OFF']}
ALLOFF = LANDING[168] + LANDING[169]
WIDE = ALLOFF + ['R11U161_OFF', 'R11U164_OFF', 'R11U167_OFF', 'R11V173_OFF']
PREOFF = ALLOFF + ['R11V173_OFF']          # must equal the edb34d8a build byte for byte
def landing_of(law):
    n = int(''.join(ch for ch in law if ch.isdigit())[-3:])
    return 168 if n in (166, 168) else 169 if n == 177 else n
