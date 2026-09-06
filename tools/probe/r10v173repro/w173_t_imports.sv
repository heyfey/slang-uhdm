// r10v173 arm T — IMPORT CLONES, three module instances, and the HOME vs CLONE
// listings scored separately.  `hearthPkg` is imported into `bellowsPkg`
// explicitly, into `fluePkg` by wildcard, and into the module by wildcard, so
// the same function is reachable under three different homes.
package hearthPkg;
  function automatic int unsigned draught(int unsigned n);
    return n + 7;
  endfunction
  function automatic int unsigned flueGas(int unsigned n);
    return draught(n) + hearthPkg::draught(n);   // own-package, both spellings
  endfunction
  task automatic vent(input int unsigned n, output int unsigned o);
    o = draught(n);
  endtask
endpackage

package bellowsPkg;
  import hearthPkg::draught;                     // EXPLICIT import
  function automatic int unsigned puff(int unsigned n);
    return draught(n) + 1;                       // through the explicit clone
  endfunction
  function automatic int unsigned puffQual(int unsigned n);
    return hearthPkg::draught(n) + 2;            // qualified, other package
  endfunction
  function automatic int unsigned puffHome(int unsigned n);
    return puff(n) + bellowsPkg::puffQual(n);    // own package, both spellings
  endfunction
endpackage

package fluePkg;
  import hearthPkg::*;                           // WILDCARD import
  function automatic int unsigned updraft(int unsigned n);
    return draught(n) + flueGas(n);              // both through the clone
  endfunction
  function automatic int unsigned updraftQual(int unsigned n);
    return hearthPkg::flueGas(n) + fluePkg::updraft(n);
  endfunction
endpackage

module ember_leaf (input int unsigned a, output int unsigned y);
  import fluePkg::*;
  assign y = updraft(a) + bellowsPkg::puffHome(a);
endmodule

module ember_top (output int unsigned e1, output int unsigned e2, output int unsigned e3);
  int unsigned v1, v2, v3;
  ember_leaf u_one  (.a(1), .y(v1));
  ember_leaf u_two  (.a(2), .y(v2));
  ember_leaf u_three(.a(3), .y(v3));
  int unsigned vt;
  initial hearthPkg::vent(4, vt);
  assign e1 = v1 + vt;
  assign e2 = v2 + fluePkg::updraftQual(5);
  assign e3 = v3 + bellowsPkg::puff(6);
endmodule
