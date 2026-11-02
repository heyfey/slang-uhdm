// § unitImpTransitiveTds464 (an enum typedef reached transitively)
package a;
  typedef enum logic [1:0] {A0, A1, A2} a_e;
endpackage
package m;
  import a::*;
  typedef logic [2:0] m_t;
endpackage
import m::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
