// r10v200 break arm 5 — the MODULE-MATERIALIZED population (uvm196's): a
// module and an interface that import the same package, one instanced twice,
// plus a package importer alongside.  The module copies MUST NOT change.
package pv5;
  parameter W5 = 8;
  function logic [W5:0] m5(input logic [W5:0] a);
    logic [W5:0] l5; l5 = a; m5 = l5;
  endfunction
endpackage

package pv5p;
  import pv5::*;
endpackage

interface if5;
  import pv5::*;
  logic [W5:0] w;
endinterface

module sub5;
  import pv5::*;
  logic [W5:0] r;
  initial r = m5('0);
endmodule

module topv5;
  import pv5::*;
  if5 i0();
  sub5 u0();
  sub5 u1();
  logic [W5:0] q;
  initial q = m5('0);
endmodule
