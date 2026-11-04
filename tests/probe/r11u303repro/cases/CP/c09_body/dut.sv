// § classParamNamedTypeTs303
package q;
  typedef logic [3:0] w_t;
endpackage
class C;
  localparam q::w_t M = 4'h4;
  logic [3:0] v = M;
endclass
module dut (output logic o);
  C c;
  assign o = 1'b0;
endmodule
