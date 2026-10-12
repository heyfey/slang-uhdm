// § inlineAggFormalTypeSpan299
module dut(input logic [1:0] i, output logic [1:0] o);
  function automatic logic [1:0] f(input union packed { logic [1:0] a; logic [1:0] b; } v);
    return v;
  endfunction
  assign o = f(i);
endmodule
