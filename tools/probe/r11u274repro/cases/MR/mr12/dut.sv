// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h040302) (output logic [7:0] o);
  localparam int Q = P.u.a + 1;
  localparam int R = P.d;
  assign imp = P.u.b[0];
  always_comb o = Q + R + {P.u.a{1'b0}};
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule
