// § unitImpTransitiveTds464 (control: an explicit file-scope import)
package a;
  typedef logic [3:0] a_t;
endpackage
package m;
  import a::*;
  typedef logic [2:0] m_t;
endpackage
import m::m_t;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
