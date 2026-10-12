// § classParamNamedTypeTs303
package q;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
class C #(parameter q::s_t M = 3'b101);
  logic [2:0] v = M;
endclass
module dut (output logic o);
  C c;
  assign o = 1'b0;
endmodule
