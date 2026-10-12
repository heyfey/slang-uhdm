// § inlineAggFormalTypeSpan299
class c;
  function logic [3:0] f(input struct packed { logic a; logic b; } [1:0] v);
    return v;
  endfunction
endclass
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
