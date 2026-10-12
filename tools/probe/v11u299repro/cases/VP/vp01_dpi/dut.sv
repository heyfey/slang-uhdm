// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  import "DPI-C" function void cf(input struct packed { logic a; logic b; } [1:0] v);
  function automatic logic [3:0] f(input struct packed { logic a; logic b; } [1:0] v);
    return v;
  endfunction
  assign o = f(i);
endmodule
