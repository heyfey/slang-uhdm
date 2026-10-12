// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] k, struct packed { logic a; logic b; } [1:0] v);
    return v ^ k;
  endfunction
  assign o = f(i, i);
endmodule
