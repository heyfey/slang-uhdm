// § classParamNamedTypeTs303
package q; typedef logic [2:0] m_t; endpackage
virtual class C #(parameter q::m_t M = 3'b010);
  logic [2:0] v = M;
endclass
class D extends C #(3'b111);
endclass
module dut (output logic [2:0] o);
  D d;
  assign o = 3'b0;
endmodule
