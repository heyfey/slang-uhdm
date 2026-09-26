// § hpDotWsTrimmed167 — no blanks (the control of w12)
typedef struct packed { logic [1:0] a; } s_t;
module top #(parameter s_t S = '{a: 2'd1}) (input logic [1:0] v, output logic y);
  for (genvar i = 0; i < 2; i++) begin : g
    wire x = v[i];
  end
  assign y = g[S.a].x;
endmodule
