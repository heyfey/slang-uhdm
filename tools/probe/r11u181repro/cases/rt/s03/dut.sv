// § rootPathFullNameByChain181 — the $root path baseline copied from tools/probe/r11u170verify cases/rt/r03 (its law there: pass 157/167)
typedef struct packed { logic [7:0] a; logic [7:0] b; } cfg_t;
module top (output logic [7:0] o);
  localparam cfg_t CFG = '{a: 8'h12, b: 8'h34};
  sub u(.o(o));
endmodule
module sub (output logic [7:0] o);
  assign o = $root.top.CFG.a ^ $root.top.CFG.b;
endmodule
