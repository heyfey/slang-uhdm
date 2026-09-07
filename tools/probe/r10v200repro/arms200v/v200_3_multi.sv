// r10v200 break arm 3 — MULTIPLICITY 1..3: three importing packages of the
// same home, a three-deep re-export chain, three subroutines, three refs each.
package pv3;
  parameter W3A = 4;
  parameter W3B = W3A*2;
  parameter W3C = W3B-1;
  function logic [W3A:0] g1(input logic [W3A:0] a);
    logic [W3A:0] l1; l1 = a; g1 = l1;
  endfunction
  function logic [W3B:0] g2(input logic [W3B:0] a);
    logic [W3B:0] l2; l2 = a; g2 = l2;
  endfunction
  function logic [W3C:0] g3(input logic [W3C:0] a);
    logic [W3C:0] l3; l3 = a; g3 = l3;
  endfunction
endpackage

package pv3i1;
  import pv3::*;
endpackage
package pv3i2;
  import pv3::*;
endpackage
package pv3i3;
  import pv3i2::*;
endpackage
package pv3i4;
  import pv3i3::*;
endpackage

module topv3;
  import pv3::*;
  initial $display(W3A);
endmodule
