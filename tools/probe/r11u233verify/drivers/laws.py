# r11u233: the law -> switch map of the two landings under verification, read from the sources at aba8c391:
#  * landing 228 (cd4fd02a, module/type ground): src/R228.h r11u228Law (R11U228_OFF or the law's own switch) for the
#    pass's three laws; r11v228Law (R11V228_OFF or own) for v11u228's three refinements.  The refinements live inside
#    the pass's laws' sites (TypeEmit resolveMemberInit, uhdm_main's parse-view $size block), so R11U228_OFF drops them
#    too; R11V228_OFF alone gives r11u228's laws as the implementer delivered them.
#  * landing 227 (9c9c11d6, expression/parameter ground): src/R227.h r11u227On (R11U227_OFF or own) for the three
#    laws; r11v227On (R11V227_OFF or own) for § fwdPkgRefConstSlotWhole227v, read inside § fwdPkgRefClassScopeSpan227's
#    drain (R11U227_OFF drops it too).  The § landingSwitchReach227 split switches are not read by R11U227_OFF.
# Pass 225's fill laws are listed so that the cross (X) cases can name them.
SW = {
 'memberInitReducedRootFolds228': ['R11U228_MEMROOTFOLD_OFF'],
 'parseViewSizeExprEval228': ['R11U228_PVSIZE_OFF'],
 'sizeBitNetIsVar228': ['R11U228_SIZEBITNET_OFF'],
 'pvSizeNoElemDeclines228v': ['R11V228_PVSIZEDYN_OFF'],
 'memberRootFoldShapes228v': ['R11V228_ROOTSHAPE_OFF'],
 'memberRootOwnInstance228v': ['R11V228_ROOTINST_OFF'],
 'fwdPkgRefClassScopeSpan227': ['R11U227_FWDPKGSPAN_OFF'],
 'fwdPkgRefConstSlotWhole227v': ['R11V227_CONSTSLOT_OFF'],
 'pkgPatFuncBodyLeftoverNoParent227': ['R11U227_PATLEFTOVER_OFF'],
 'newArrayPartSelStripped227': ['R11U227_NEWARRPS_OFF'],
 # carried (the cross-ground partners)
 'initHierFillKept225': ['R11U225_INITHIERFILL_OFF'],
 'fillSymbolicRootOnly225v': ['R11V225_FILLSYM_OFF'],
 'fullNameDrainIdOrder226v': ['R11V226_IDORDER_OFF'],
}
PARENT = {'pvSizeNoElemDeclines228v': 'parseViewSizeExprEval228',
          'memberRootFoldShapes228v': 'memberInitReducedRootFolds228',
          'memberRootOwnInstance228v': 'memberInitReducedRootFolds228',
          'fwdPkgRefConstSlotWhole227v': 'fwdPkgRefClassScopeSpan227',
          'fillSymbolicRootOnly225v': 'initHierFillKept225'}
LAND = {}
for _l in SW:
    if _l.endswith(('228', '228v')): LAND[_l] = 228
    elif _l.endswith(('227', '227v')): LAND[_l] = 227
    elif _l.endswith(('225', '225v')): LAND[_l] = 225
    elif _l.endswith('226v'): LAND[_l] = 226
LANDING = {228: ['R11U228_OFF'], 227: ['R11U227_OFF'], 225: ['R11U225_OFF', 'R11V225_OFF'], 226: ['R11V226_OFF']}
# ALLOFF: both landings off = the bytes of 97343175 before cd4fd02a (pass 228) and 9c9c11d6 (pass 227)
ALLOFF = ['R11U227_OFF', 'R11U228_OFF']
# WIDE here = IMPL: both verifiers' refinements off = the two passes' laws as their implementers delivered them
WIDE = ['R11V227_OFF', 'R11V228_OFF']
TRACES = ['R11U227_TRACE', 'R11U228_TRACE']
def landing_of(law):
    return LAND.get(law)
