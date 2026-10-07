// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h020304) (output logic [15:0] o);
  logic [P.u.a-1:0] v;
  assign v = '1;
  assign o = {P.u.b{1'b1}};
endmodule
module dut(output logic [15:0] o); kid k0 (.o(o)); endmodule
