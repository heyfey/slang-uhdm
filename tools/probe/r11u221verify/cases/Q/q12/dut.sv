// § genScopeRangeQueryFold216 + § ndaRangeQueryFold216 — select and member operands (a struct member, a bit-select of a 2-D net: declined shapes) beside a plain query
module dut (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  typedef struct packed { logic [6:2] f; logic g; } s_t;
  s_t s;
  logic [2:0][5:1] m;
  wire [7:0] w1 = $high(s.f);
  wire [7:0] w2 = $low(m[1]);
  for (genvar i = 0; i < 1; i++) begin : g
    assign o3 = $high(m);
  end
  assign o1 = w1;
  assign o2 = w2;
endmodule
