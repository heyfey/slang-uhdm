// § classParamNamedTypeTs303
package q; typedef logic [2:0] m_t; endpackage
class C;
  localparam q::m_t L = 3'b101;
  parameter q::m_t K = 3'b011;
  logic [2:0] v = L ^ K;
endclass
module dut (output logic [2:0] o);
  C c;
  assign o = 3'b0;
endmodule
