// § classParamNamedTypeTs303
package q;
  typedef int i_t;
endpackage
class C #(parameter q::i_t M = 5);
  int v = M;
endclass
module dut (output logic o);
  C #(7) c;
  assign o = 1'b0;
endmodule
