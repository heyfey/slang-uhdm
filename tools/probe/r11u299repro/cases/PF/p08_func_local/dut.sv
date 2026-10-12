// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v);
    struct packed { logic a; logic b; } [1:0] l;
    l = v;
    return l;
  endfunction
  assign o = f(i);
endmodule
