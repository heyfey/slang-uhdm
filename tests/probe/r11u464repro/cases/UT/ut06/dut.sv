// § unitImpTransitiveTds464 (the transitive package also imported directly)
package a;
  typedef logic [3:0] a_t;
  typedef logic [5:0] z_t;
endpackage
package m;
  import a::*;
  typedef logic [2:0] m_t;
endpackage
import m::*;
import a::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
