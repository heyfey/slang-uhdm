// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [3:0] c; logic [3:0] e; } l3_t;
  typedef struct packed { l3_t b; logic [7:0] f; } l2_t;
  typedef struct packed { l2_t a; logic [7:0] g; } l1_t;
endpackage
module kid #(parameter pk::l1_t P = 24'h123456) (output logic [3:0] o, output logic [7:0] o2);
  always_comb o = P.a.b.c;
  always_comb o2 = P.a.f;
endmodule
module dut(output logic [3:0] o, output logic [7:0] o2); kid k0 (.o(o), .o2(o2)); endmodule
