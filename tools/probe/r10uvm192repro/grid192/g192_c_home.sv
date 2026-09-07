// r10uvm192 ARM C — THE HOME/IMPORTER SPLIT, the term the uvm-1.2 rows
// convict.  MEASUREMENT ONLY.
//
// `hearthPkg` OWNS `Anvil`; `forgePkg` WILDCARD-IMPORTS it, so forgePkg's own
// listing carries `Anvil::weight` CLONES of everything hearthPkg owns.  The
// law must fire in hearthPkg's own bodies and NOWHERE ELSE: not in forgePkg's
// clone of `Anvil::homeCaller`, and not in forgePkg's own `Bellows::gust`.
package hearthPkg;
  class Anvil;
    extern static function int weight();
    extern static function int homeCaller();
  endclass
  function int Anvil::weight();
    return 21;
  endfunction
  function int Anvil::homeCaller();
    return Anvil::weight();
  endfunction
endpackage

package forgePkg;
  import hearthPkg::*;
  class Bellows;
    extern static function int gust();
    extern static function int ownCaller();
  endclass
  function int Bellows::gust();
    return 29;
  endfunction
  // An IMPORTER's body calling an IMPORTED class's static: home is hearthPkg,
  // this listing is forgePkg's, so the split must hold the cell still.
  function int Bellows::ownCaller();
    return Anvil::weight() + Bellows::gust();
  endfunction
endpackage

package anvilPkg;
  // A package whose NAME collides with nothing, calling ACROSS packages with
  // an explicit three-segment spelling.
  import hearthPkg::*;
  function automatic int reach();
    return hearthPkg::Anvil::weight();
  endfunction
endpackage

module forge_top;
  import forgePkg::*;
  int r;
  initial r = Bellows::ownCaller();
endmodule
