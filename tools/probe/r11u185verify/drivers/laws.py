# r11u185: the law -> switch map of the two landings under verification (pass 176 = r11u175's extern-prototype law +
# fourteen r11u176 laws + v11u176's refinement, 804e3b75; pass 178 = r11u175's three expression laws + two r11u178
# laws + r11v178's two refinements, 80a1c2af), and of the landings the composition census also switches.
SW = {
 # landing 176 (804e3b75)
 'externProtoFormalsFromPrototype175': ['R11U175_FSPAN_OFF'],
 'castRhsClonePerInst176': ['R11U176_CASTCLONE_OFF'],
 'progTypedPortLowConnUnlocated176': ['R11U176_PROGLCLOC_OFF'],
 'progLowConnDefModport176': ['R11U176_PROGMPDEF_OFF'],
 'progPlainPortViewUnparented176': ['R11U176_PROGVIEW_OFF'],
 'genericMpConnLowConnAtDecl176': ['R11U176_GENMPLOC_OFF'],
 'genericPlainNamedView176': ['R11U176_GENPLAINLOC_OFF', 'R11U176_GENPLAINVARS_OFF'],
 'tfArgQualOutsideWriter176': ['R11U176_QUALFORMAL_OFF'],
 'tfArgClassMethodOrder176': ['R11U176_CLSMETHOD_OFF'],
 'tfArgDefTopSplit176': ['R11U176_DEFTOPSPLIT_OFF'],
 'tdEndMoveModuleOrder176': ['R11U176_TDTIE_OFF'],
 'tdMoveKeyResolved176': ['R11U176_TDKEY_OFF'],
 'udpFormNetLvalueFirst176': ['R11U176_UDPLV_OFF'],
 'genElseBeginIfDepth176': ['R11U176_ELSEBEGIN_OFF'],
 'genElseIfGateArrayPath176': ['R11U176_GENARR_OFF'],
 'tdKeyKeepsUnresolved176v': ['R11V176_TDKEYUNRES_OFF'],
 # landing 178 (80a1c2af)
 'importCloneBodyLocalCopies175': ['R11U175_MULT_OFF'],
 'refFullNameThroughNamedExpr175': ['R11U175_FULLNAME_OFF'],
 'doWhileSpansToCloseParen175': ['R11U175_ESPAN_OFF'],
 'hierPathSelIdxAtPath178': ['R11U178_MIDIDX_OFF', 'R11U178_MIDIDXNAME_OFF'],
 'pkgPatUnqualReadTsNoParent178': ['R11U178_PATUNQUAL_OFF'],
 'hierPathSelIdxCloneKeepsElem178v': ['R11V178_INCDEC_OFF', 'R11V178_ELABCA_OFF'],
 'doWhileEndsAtCondEnd178v': ['R11V178_DWCOND_OFF'],
 # cross-ground partners (passes 169, 171 and r11u177)
 'tdMoveCarriesFile172': ['R11U172_FILE_OFF'], 'mlArgLocFileAtActual177v': ['R11V177_MLARGFILE_OFF'],
 'memLeftFormalArgLoc169': ['R11U169_MLARGLOC_OFF'], 'genCaFoldTsChainNamed169': ['R11U169_GCACHAIN_OFF'],
}
PARENT = {'tdKeyKeepsUnresolved176v': 'tdMoveKeyResolved176',
          'hierPathSelIdxCloneKeepsElem178v': 'hierPathSelIdxAtPath178',
          'doWhileEndsAtCondEnd178v': 'doWhileSpansToCloseParen175'}
LANDING = {176: ['R11U175_FSPAN_OFF', 'R11U176_OFF'],            # R11U176_OFF also drops R11V176_TDKEYUNRES_OFF's refinement
           178: ['R11U178_OFF', 'R11V178_OFF'],                  # R11U178_OFF drops the three expression r11u175 laws too
           172: ['R11U172_OFF'], 169: ['R11U169_OFF'], 177: ['R11V177_OFF']}
ALLOFF = ['R11U175_OFF', 'R11U176_OFF', 'R11U178_OFF', 'R11V178_OFF']
PREOFF = ALLOFF + ['R11U181_OFF', 'R11V181_OFF']        # must equal the 312e26e2 build byte for byte
OTHERS = ['R11U172_OFF', 'R11U171_OFF', 'R11V171_OFF', 'R11U174_OFF', 'R11V174_MOPPKG_OFF', 'R11U181_OFF', 'R11V181_OFF',
          'R11V177_OFF', 'R11V182_OFF']
WIDE = ALLOFF + OTHERS
L176 = {'externProtoFormalsFromPrototype175', 'castRhsClonePerInst176', 'progTypedPortLowConnUnlocated176',
        'progLowConnDefModport176', 'progPlainPortViewUnparented176', 'genericMpConnLowConnAtDecl176',
        'genericPlainNamedView176', 'tfArgQualOutsideWriter176', 'tfArgClassMethodOrder176', 'tfArgDefTopSplit176',
        'tdEndMoveModuleOrder176', 'tdMoveKeyResolved176', 'udpFormNetLvalueFirst176', 'genElseBeginIfDepth176',
        'genElseIfGateArrayPath176', 'tdKeyKeepsUnresolved176v'}
L178 = {'importCloneBodyLocalCopies175', 'refFullNameThroughNamedExpr175', 'doWhileSpansToCloseParen175',
        'hierPathSelIdxAtPath178', 'pkgPatUnqualReadTsNoParent178', 'hierPathSelIdxCloneKeepsElem178v',
        'doWhileEndsAtCondEnd178v'}
def landing_of(law):
    if law in L176: return 176
    if law in L178: return 178
    if law.endswith('177v'): return 177
    if law.endswith('172'): return 172
    return 169
