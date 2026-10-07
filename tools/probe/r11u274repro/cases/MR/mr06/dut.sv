// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; } l3_t;
  typedef struct packed { l3_t x; logic [7:0] b; } l2_t;
  typedef struct packed { l2_t y; logic [7:0] c; } l1_t;
endpackage
module kid #(parameter pk::l1_t P = '0) (output logic [7:0] o, output logic [7:0] o2);
  always_comb begin o = P.y.x.a; o2 = P.y.b + P.c; end
endmodule
module dut(output logic [7:0] o, o2); kid k0 (.o(o), .o2(o2)); endmodule
