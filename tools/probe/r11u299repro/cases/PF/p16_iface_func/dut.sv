// § inlineAggFormalTypeSpan299
interface ifc;
  function automatic logic [3:0] f(input struct packed { logic a; logic b; } [1:0] v);
    return v;
  endfunction
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign o = u.f(i);
endmodule
