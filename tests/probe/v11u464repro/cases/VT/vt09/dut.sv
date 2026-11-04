// § unitImpTransitiveTds464 (a re-exporting package used by the module)
package a;
  typedef logic [3:0] a_t;
endpackage
package m;
  import a::*;
  export *::*;
  typedef logic [2:0] m_t;
  typedef a_t m2_t;
  localparam a_t K = 4'd3;
endpackage
import m::*;
module top(input logic [1:0] i, output logic [3:0] o);
  a_t v;
  assign v = {2'b0, i} + K;
  assign o = v;
endmodule
