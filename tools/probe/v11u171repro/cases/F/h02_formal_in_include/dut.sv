// § tdMoveCarriesFile172
package pb;
`include "fn.svh"
endpackage
module dut(input pa::s_t i, output logic o);
  assign o = pb::f(i);
endmodule
