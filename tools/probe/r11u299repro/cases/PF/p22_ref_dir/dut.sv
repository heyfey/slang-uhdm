// § inlineAggFormalTypeSpan299
class c;
  function void f(ref struct packed { logic a; logic b; } [1:0] v);
    v = '0;
  endfunction
endclass
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
