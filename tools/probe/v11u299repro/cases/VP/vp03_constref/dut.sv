// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(const ref struct packed { logic a; logic b; } [1:0] v);
    return v;
  endfunction
  logic [3:0] x;
  always_comb begin x = i; o = f(x); end
endmodule
