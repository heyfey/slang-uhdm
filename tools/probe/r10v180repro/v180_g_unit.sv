// r10v180 arm G — $unit AND MODULE SCOPE (legal form: a package may not
// reference a compilation-unit item, so $unit is exercised where it is legal).
// A compilation-unit typedef, a module-scope typedef and a package typedef of
// the SAME shape all live at once, and the module's own subroutine declares
// block locals of ALL THREE.  Nothing outside a package CLONE body may move.
typedef logic [10:0] gantry_ut;

package Dock_pk;
  typedef logic [10:0] gantry_pt;
  function automatic int unsigned crane_fn(gantry_pt lift);
    gantry_pt hoist;
    hoist = lift;
    begin
      gantry_pt spar;
      spar = gantry_pt'(hoist + 1);
      hoist = spar;
    end
    return int'(hoist);
  endfunction
endpackage
package Dock_imp;
  import Dock_pk::*;
endpackage
module Dock_top;
  import Dock_pk::*;
  typedef logic [10:0] gantry_mt;
  gantry_pt quay;
  gantry_mt berth;
  gantry_ut wharf;
  int unsigned r;
  function automatic int unsigned mod_fn(gantry_mt m);
    gantry_mt inner;
    gantry_pt pk_local;
    gantry_ut unit_local;
    inner = m;
    begin
      gantry_mt deep;
      gantry_pt pdeep;
      gantry_ut udeep;
      deep = inner;
      pdeep = gantry_pt'(deep);
      udeep = gantry_ut'(pdeep);
      pk_local = pdeep;
      unit_local = udeep;
    end
    return int'(inner) + int'(pk_local) + int'(unit_local);
  endfunction
  initial begin
    quay = 11'h1a5;
    berth = 11'h0c3;
    wharf = 11'h07f;
    r = crane_fn(quay) + mod_fn(berth) + int'(wharf);
  end
endmodule
