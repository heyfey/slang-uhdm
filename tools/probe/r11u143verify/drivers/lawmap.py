#!/usr/bin/env python3
"""lawmap.py: case group -> (law, its own switch, extra env for law off). A3 = the three landings off."""
A3='R11U133_OFF,R11V141_OFF,R11U137_OFF,R11U139_OFF,R11V137_OFF'
M={
 'p133_lhsclone':('impPaLhsDisjointClone133','R11U133_LHSCLONE_OFF'),
 'p133_hpmid':('hpBaseSelMidMemberBare133','R11U133_HPMID_OFF'),
 'p133_trailidx':('hpTrailSelIdxNamesByPath133','R11U133_TRAILIDX_OFF'),
 'p133_patqual':('elabPatQualRefQualSpan133','R11U133_PATQUAL_OFF'),
 'p133_unkfile':('unknownParamOperandFile133','R11U133_UNKFILE_OFF'),
 'p141_inctabact':('includeInactiveTabNotText141v','R11V141_INCTABACT_OFF'),
 'p141_ipsqual':('ipsQualBaseRangeSpan141v','R11V141_IPSQUAL_OFF'),
 'p137_elabclone':('elabCloneFullNameUnstored137','R11U137_ELABCLONE_OFF'),
 'p137_patd':('packedArrTdElemRefName137','R11U137_PATD_OFF'),
 'p137_emptyconn':('emptyNamedConnLowConnAtDecl137','R11U137_EMPTYCONN_OFF'),
 'p137_unsigned':('unsignedScalarVecTsAtKeyword137','R11U137_UNSIGNEDSPAN_OFF'),
 'p137_defwire':('unsignedScalarVecTsAtKeyword137 / R11V137_DEFWIRE','R11V137_DEFWIRE_OFF'),
 'p137_callspan':('constCallNameSpan137','R11U137_CALLSPAN_OFF'),
 'p137_repl':('connReplTsRefThroughPort137','R11U137_REPLTSNAME_OFF'),
 'p137_purevirt':('pureVirtProtoSpan137','R11U137_PUREVIRTSPAN_OFF'),
 'p137_tagged':('taggedUnionElabSpan137','R11U137_TAGGEDSPAN_OFF'),
 'p137_defnettp':('defNetTypeParamDefault137','R11U137_DEFNETTP_OFF'),
 'p137_aliasfile':('aliasCloneTakesTargetFile137','R11U137_ALIASFILE_OFF'),
 'p137_scopedarrtd':('defNetScopedPkgArrTdShares137','R11U137_SCOPEDARRTD_OFF'),
 'p137_pathbase':('structParamPathBaseAtMember137','R11U137_PATHBASE_OFF'),
 'p139_ca':('caLhsDefNetUnlessOpRhs139','R11U139_CA_OFF'),
 'p139_nda':('ndaLeftmostLeafElab139','R11U139_NDA_OFF'),
 'p139_clk':('clockingEventDefNet139','R11U139_CLK_OFF'),
 'fence_s3':('residue S3 (N0057), no landed law','R11U137_OFF'),
 'xg_pairs':('cross-ground pairs','R11U133_OFF'),
 'p139_port':('connLeftmostLeafElab139','R11U139_PORT_OFF'),
}
# extra switches worth a column for some groups (the refinement inside a law's grid)
EXTRA={'p137_purevirt':['R11V137_PVQUAL_OFF'],'p137_unsigned':['R11V137_DEFWIRE_OFF'],'p137_defwire':['R11U137_UNSIGNEDSPAN_OFF']}
