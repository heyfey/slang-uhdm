// § rootPathFullNameByChain181 — the $root path baseline copied from tools/probe/r11u170verify cases/rt/r04 (its law there: pass 157/167)
typedef struct packed { logic [7:0] a; logic [7:0] b; } cfg_t;
module top (output logic [7:0] o [2]);
  localparam cfg_t CFG = '{a: 8'h12, b: 8'h34};
  for (genvar g = 0; g < 2; g++) begin : G
    logic [7:0] r;
    always_comb r = g ? $root.top.CFG.a : $root.top.CFG.b;
    assign o[g] = r;
  end
endmodule
