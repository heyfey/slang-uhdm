// § classParamNamedTypeTs303
package q;
  typedef logic [3:0] w_t;
endpackage
class C #(parameter q::w_t M = 4'h1, parameter q::w_t N = 4'h2);
  logic [3:0] v = M ^ N;
endclass
module dut (output logic o);
  C #(4'h5, 4'h6) c;
  assign o = 1'b0;
endmodule
