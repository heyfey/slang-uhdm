// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid import pk::*; #(parameter c_t P = 24'h010203) (output logic [7:0] o); always_comb o = P.u.a; endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule
