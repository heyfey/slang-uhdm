// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  task automatic t(input struct packed { logic a; logic b; } [1:0] v, output logic [3:0] r);
    r = v;
  endtask
  always_comb t(i, o);
endmodule
