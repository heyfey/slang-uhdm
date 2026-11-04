// § genLoopDirectBoundPaConst262 (a generate-local left side two generate levels deep is not the top-level window; and a member left side)
module ctrl (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  typedef struct packed { logic [1:0] f; } s_t;
  s_t sv;
  for (genvar h = 0; h < 1; h++) begin : gf
    assign sv.f = a[K +: 2] & 2'b10;
  end
  assign q = sv.f;
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
