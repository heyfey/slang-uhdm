// § unitImpTransitiveTds464 (two modules in the importing file)
package a;
  typedef logic [3:0] a_t;
endpackage
package m;
  import a::*;
  typedef logic [2:0] m_t;
endpackage
import m::*;
module sub(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
module top(input logic [1:0] i, output logic [1:0] o);
  sub u(.i(i), .o(o));
endmodule
