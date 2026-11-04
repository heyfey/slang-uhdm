// § inlineAggFormalTypeSpan299
module dut(input logic [1:0] i, output logic [1:0] o);
  task automatic t(union packed { logic [1:0] a; logic [1:0] b; } v, output logic [1:0] z);
    z = v;
  endtask
  always_comb t(i, o);
endmodule
