// § inlineAggFormalTypeSpan299
package p;
  function automatic logic [3:0] f(input struct packed { logic a; logic b; } [1:0] v);
    return v;
  endfunction
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = p::f(i);
endmodule
