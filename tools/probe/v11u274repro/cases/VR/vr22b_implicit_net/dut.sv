// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (output logic [7:0] o);
  assign w = P.u.a[0];
  always_comb o = {7'b0, w};
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule
