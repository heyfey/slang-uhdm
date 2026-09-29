# r11u229: the law -> switch map of the three landings under verification, read from the sources at 01dc93ab:
#  * landing 224 (ac0dda58, expression/parameter ground): src/R224.h r11u224On (R11U224_OFF or the law's own switch).
#    R11U224_OFF drops the eleven laws; the four § landingSwitchReach224 split switches are NOT read by it (by
#    default they change nothing: they split older laws that stay on).
#  * landing 225 (1a30095a, module/type ground): src/R225.h r11u225Law (R11U225_OFF or own) and r11v225Law
#    (R11V225_OFF or own) for § fillSymbolicRootOnly225v, which only restricts § initHierFillKept225.
#  * r11u226 (01dc93ab): src/R226.h r11v226Law (R11V226_OFF or own); § tfArgScalarTdExportOwnTd226v is also dropped
#    by R11U223_OFF (its parent's landing switch, TaskFuncEmit).
# Pass 223's two formal laws and pass 220's name laws are listed so that the X (cross) cases can name them.
SW = {
 'strLitPpEscIdShift224': ['R11U224_STRPPESC_OFF'],
 'strLitContOwnerEnd224': ['R11U224_STRCONTOWN_OFF'],
 'ipsBasePfxScopeJoin224': ['R11U224_IPSPFXJOIN_OFF'],
 'ipsWidthPfxByPathInScope224': ['R11U224_IPSWIDTH_OFF'],
 'hpLvSelIdxNamesByPath224': ['R11U224_LVSELIDX_OFF'],
 'hpLvSelColumnJoin224': ['R11U224_LVSELCOL_OFF'],
 'hpLvNewClassFirstElemSpan224': ['R11U224_LVNEWSPAN_OFF'],
 'newArrayBitSelIdxOpStripped224': ['R11U224_NEWARRIDXOP_OFF'],
 'newArrayVarSelStripped224': ['R11U224_NEWARRVS_OFF'],
 'sysCallTypeArgScopeJoin224': ['R11U224_SYSTYPEJOIN_OFF'],
 'pcwAllPkgListingBindsOwn224': ['R11U224_PCWALLPKG_OFF'],
 'ifArrElemLitCaFresh225': ['R11U225_IFARRELEMCA_OFF'],
 'initHierAtRefToken225': ['R11U225_INITHIERSPAN_OFF'],
 'initHierCaLhsBareName225': ['R11U225_INITHIERCANAME_OFF'],
 'initHierFillKept225': ['R11U225_INITHIERFILL_OFF'],
 'fillSymbolicRootOnly225v': ['R11V225_FILLSYM_OFF'],
 'tfArgScalarTdExportOwnTd226v': ['R11V226_EXPOWNTD_OFF'],
 'fullNameDrainIdOrder226v': ['R11V226_IDORDER_OFF'],
 # carried (the parents and cross-ground partners)
 'tfArgScalarTdWriter223': ['R11U223_SCALARTDTOK_OFF'],
 'tfArgScalarTdExportFirst223': ['R11U223_SCALARTDEXP_OFF'],
 'strLitContLineSpan220': ['R11U220_STRCONT_OFF'],
 'strLitShiftNeedsBacktick220': ['R11U220_STRSHIFT_OFF'],
 'hpVarSelRangeIdxNamesByPath220': ['R11U220_HPVSIDX_OFF'],
 'hpVarSelColumnJoin220': ['R11U220_HPVSCOL_OFF'],
 'cloneHpIdxNamesByChain220': ['R11U220_CLONEIDX_OFF'],
 'hpTrailIpsNamesByPath218': ['R11U218_HPIPSNAME_OFF'],
 'lvIdxPathRangeTailIsRead218': ['R11U218_LVIDXPS_OFF'],
}
PARENT = {'fillSymbolicRootOnly225v': 'initHierFillKept225',
          'tfArgScalarTdExportOwnTd226v': 'tfArgScalarTdExportFirst223',
          'hpLvSelColumnJoin224': 'hpLvSelIdxNamesByPath224',
          'ipsWidthPfxByPathInScope224': 'ipsBasePfxScopeJoin224'}
LAND = {}
for _l in SW:
    if _l.endswith('226v'): LAND[_l] = 226
    elif _l.endswith('224'): LAND[_l] = 224
    elif _l.endswith(('225', '225v')): LAND[_l] = 225
    elif _l.endswith(('223', '223v')): LAND[_l] = 223
    elif _l.endswith(('218', '220')): LAND[_l] = 220
LANDING = {224: ['R11U224_OFF'], 225: ['R11U225_OFF', 'R11V225_OFF'], 226: ['R11V226_OFF'],
           223: ['R11U223_OFF'], 220: ['R11U220_OFF']}
# ALLOFF: the three landings under verification off = the bytes of 4a620bd0 (r11u226's base)
ALLOFF = ['R11U224_OFF', 'R11U225_OFF', 'R11V225_OFF', 'R11V226_OFF']
# WIDE: ALLOFF + passes 220 and 223 (the partners of the cross-ground pairs)
WIDE = ALLOFF + ['R11U220_OFF', 'R11U223_OFF']
TRACES = ['R11U224_TRACE', 'R11U225_TRACE', 'R11V226_TRACE', 'R11U223_TRACE', 'R11U220_TRACE']
def landing_of(law):
    return LAND.get(law)
