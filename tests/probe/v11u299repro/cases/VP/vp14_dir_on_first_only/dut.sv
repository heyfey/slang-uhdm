// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(output logic [3:0] z, struct packed { logic a; logic b; } [1:0] v);
    z = i; v = i; return i;
  endfunction
  logic [3:0] zz, vv;
  always_comb o = f(zz, vv);
endmodule
