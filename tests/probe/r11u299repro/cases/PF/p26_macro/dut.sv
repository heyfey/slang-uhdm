// § inlineAggFormalTypeSpan299
`define ST struct packed { logic a; logic b; } [1:0]
module dut(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(input `ST v);
    return v;
  endfunction
  assign o = f(i);
endmodule
