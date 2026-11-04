// § classParamNamedTypeTs303
package q; typedef logic [2:0] m_t; endpackage
class C #(parameter q::m_t M = 3'b010);
  logic [2:0] v = M;
endclass
module dut (output logic [2:0] o);
  assign o = 3'b0;
endmodule
