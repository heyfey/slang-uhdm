// § classParamNamedTypeTs303
package q;
  typedef logic [2:0] m_t;
  class C #(parameter m_t M = 3'b010);
    logic [2:0] v = M;
  endclass
endpackage
module dut (output logic [2:0] o);
  q::C #(3'b011) c;
  assign o = 3'b0;
endmodule
