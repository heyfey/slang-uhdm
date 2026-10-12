// § inlineAggFormalTypeSpan299
module dut(input logic [11:0] i, output logic [11:0] o);
  function automatic logic [11:0] f(input struct packed { logic a; logic b; } [1:0][2:0] v);
    return v;
  endfunction
  assign o = f(i);
endmodule
