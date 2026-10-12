// § classParamNamedTypeTs303
package q;
  typedef logic [3:0] w_t;
endpackage
import q::*;
class C #(parameter w_t M = 4'h3);
  logic [3:0] v = M;
endclass
module dut (output logic [3:0] o);
  C c;
  assign o = 4'b0;
endmodule
