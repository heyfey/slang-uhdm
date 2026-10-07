// § elabMemberReadCopyChain274
typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
module kid #(parameter s_t P = '{a: 3, b: 4}) (input logic [7:0] x, output logic [7:0] o);
  logic [7:0] P_a;
  task automatic t(output logic [7:0] y); y = P.a; endtask
  always_comb begin t(P_a); o = P_a + x + P.b; end
  `define RD(p) p.a
  assign P_a = `RD(P);
endmodule
module dut(input logic [7:0] x, output logic [7:0] o); kid k0 (.x(x), .o(o)); endmodule
