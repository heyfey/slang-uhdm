// § unitImpTransitiveTds464 (control: the chain through an explicit body import)
package a;
  typedef logic [3:0] a_t;
  typedef logic [5:0] z_t;
endpackage
package m;
  import a::a_t;
  typedef logic [2:0] m_t;
endpackage
import m::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
