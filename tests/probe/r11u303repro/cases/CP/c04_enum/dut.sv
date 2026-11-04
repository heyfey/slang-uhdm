// § classParamNamedTypeTs303
package q;
  typedef enum logic [1:0] {A, B, C2} e_t;
endpackage
class C #(parameter q::e_t M = q::B);
  q::e_t v = M;
endclass
module dut (output logic o);
  C c;
  assign o = 1'b0;
endmodule
