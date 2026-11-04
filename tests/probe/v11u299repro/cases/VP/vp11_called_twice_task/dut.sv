// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o, q);
  task automatic t(input struct packed { logic a; logic b; } [1:0] v, output logic [3:0] z);
    z = v;
  endtask
  always_comb t(i, o);
  always_comb t(~i, q);
endmodule
