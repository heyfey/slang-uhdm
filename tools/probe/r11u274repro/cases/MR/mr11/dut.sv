// § elabMemberReadCopyChain274
typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
module kid #(parameter s_t P = '{a: 3, b: 4}) (output logic [7:0] o);
  logic [7:0] q;
  always_comb begin q = 0; q++; o = q + P.a; end
  always_comb begin int k; k = P.b; end
endmodule
module dut(output logic [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    kid k (.o());
  end
  kid k2 (.o(o));
endmodule
