// § inlineAggFormalTypeSpan299
module dut(input logic [1:0] i, output logic [1:0] o);
  function automatic logic [1:0] f(input struct packed { logic a; logic b; } v);
    return v;
  endfunction
  assign o = f(i);
endmodule
