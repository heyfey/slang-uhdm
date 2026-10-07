// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (output logic [7:0] o, output logic [7:0] o2);
  always_comb o = P.u.a;
  always_comb o2 = P.u.a + P.u.b + P.d;
endmodule
module dut(output logic [7:0] o, output logic [7:0] o2); kid k0 (.o(o), .o2(o2)); kid #(.P('1)) k1 (.o(), .o2()); endmodule
