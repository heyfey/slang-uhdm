// § inlineAggFormalTypeSpan299
interface ifc;
  logic [3:0] w;
  task automatic t(input struct packed { logic a; logic b; } [1:0] v); w = v; endtask
  modport mp (import t, output w);
endinterface
module c (ifc.mp p, input logic [3:0] i);
  always_comb p.t(i);
endmodule
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  c x (.p(u), .i(i));
  assign o = u.w;
endmodule
