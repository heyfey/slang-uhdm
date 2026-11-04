// § elabMemberReadCopyChain274
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
endpackage
module kid #(parameter pk::c_t P = 24'h010203) (output logic [7:0] o [2][2]);
  for (genvar i = 0; i < 2; i++) begin : g1
    for (genvar j = 0; j < 2; j++) begin : g2
      always_comb o[i][j] = P.u.a + i + j;
    end
  end
endmodule
module dut(output logic [7:0] o [2][2]); kid k0 (.o(o)); endmodule
