// r10v140 arm R — the alias lives in a DIFFERENT package from its base and is
// reached by wildcard import, explicit single import, and fully-qualified
// pkg::name; three aliases of one base; a class-scope alias that SHADOWS a
// package alias of the same name (declaration order matters).
package Ember_pkg;
  typedef enum bit [2:0] { EMBER_COLD = 1, EMBER_WARM = 2, EMBER_HOT = 4 } heatBand;
  typedef struct packed { bit [3:0] joules; } emberWord;
endpackage

package Forge_pkg;
  import Ember_pkg::heatBand;
  import Ember_pkg::emberWord;
  typedef Ember_pkg::heatBand HeatBand_e;
  typedef heatBand heat_band_alias2;
  typedef Ember_pkg::heatBand HeatBand_third;
  typedef Ember_pkg::emberWord EmberWord_s;

  function HeatBand_e forgeWild(); return Ember_pkg::EMBER_WARM; endfunction
  function heat_band_alias2 forgeAlt(); return Ember_pkg::EMBER_HOT; endfunction
  function Forge_pkg::HeatBand_third forgeQual(); return Ember_pkg::EMBER_COLD; endfunction
  function Ember_pkg::heatBand forgeBase(); return Ember_pkg::EMBER_HOT; endfunction
  function EmberWord_s forgeWord(); EmberWord_s w; return w; endfunction
endpackage

module bellows_top;
  import Forge_pkg::*;
  import Ember_pkg::*;
  function HeatBand_e wildAlias(); return EMBER_COLD; endfunction
  function Ember_pkg::heatBand qualBase(); return EMBER_HOT; endfunction
  function Forge_pkg::HeatBand_e qualAlias(); return EMBER_WARM; endfunction

  class Anvil;
    typedef Ember_pkg::heatBand HeatBand_e;   // SHADOWS Forge_pkg::HeatBand_e
    function HeatBand_e clsShadowed(); return EMBER_WARM; endfunction
    function Forge_pkg::HeatBand_e clsOuter(); return EMBER_HOT; endfunction
    function Ember_pkg::emberWord clsBaseWord(); Ember_pkg::emberWord w; return w; endfunction
    function EmberWord_s clsAliasWord(); EmberWord_s w; return w; endfunction
  endclass
  Anvil anv;
  HeatBand_e hb;
  initial hb = wildAlias();
endmodule
