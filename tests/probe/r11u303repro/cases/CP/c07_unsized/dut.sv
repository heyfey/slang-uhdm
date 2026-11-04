// § classParamNamedTypeTs303
package q;
  typedef logic [7:0] w_t;
endpackage
class C #(parameter q::w_t M = 5);
  logic [7:0] v = M;
endclass
module dut (output logic o);
  C c;
  assign o = 1'b0;
endmodule
