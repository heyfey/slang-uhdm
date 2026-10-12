// § classParamNamedTypeTs303
package q; typedef struct packed { logic [1:0] a; logic b; } s_t; endpackage
class C #(parameter q::s_t S = '{a: 2'b01, b: 1'b1});
  logic [2:0] v = S;
endclass
module dut (output logic [2:0] o);
  C #() c;
  assign o = 3'b0;
endmodule
