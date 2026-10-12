// § inlineAggFormalTypeSpan299
module dut(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [1:0][1:0] v);
    return v;
  endfunction
  assign o = f(i);
endmodule
