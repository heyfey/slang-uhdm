// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  task automatic t(input logic [3:0] x, output struct packed { logic a; logic b; } [1:0] v);
    v = x;
  endtask
  always_comb t(i, o);
endmodule
