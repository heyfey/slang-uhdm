// § inlineAggFormalTypeSpan299
program prg (input logic [3:0] i);
  function automatic logic [3:0] f(input struct packed { logic a; logic b; } [1:0] v);
    return v;
  endfunction
  logic [3:0] o;
  initial o = f(i);
endprogram
module dut(input logic [3:0] i);
  prg p (i);
endmodule
