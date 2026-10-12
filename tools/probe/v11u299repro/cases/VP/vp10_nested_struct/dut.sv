// § inlineAggFormalTypeSpan299
module dut(input logic [5:0] i, output logic [5:0] o);
  function automatic logic [5:0] f(input struct packed { struct packed { logic a; logic b; } s; logic c; } [1:0] v);
    return v;
  endfunction
  assign o = f(i);
endmodule
