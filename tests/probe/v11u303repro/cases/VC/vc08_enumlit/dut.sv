// § classParamNamedTypeTs303
package q; typedef enum logic [1:0] {A, B, C2} e_t; endpackage
class C #(parameter q::e_t E = q::B);
  logic [1:0] v = E;
endclass
module dut (output logic [2:0] o);
  C #() c;
  assign o = 3'b0;
endmodule
