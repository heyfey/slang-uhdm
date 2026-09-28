// § elabIfArrIdxChainName205 — i04: struct-array element member targets (not an interface) in a for-generate, literal and reading right sides
typedef struct packed { logic a; logic [1:0] b; } s_t;
module dut(input logic [1:0] x, output s_t o);
  s_t s [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign s[i].a = 1'b1;
    assign s[i].b = x;
  end
  assign o = s[1];
endmodule
